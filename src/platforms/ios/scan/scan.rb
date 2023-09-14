require 'net/http'
require 'multipart_body'
require 'uri'
require 'json'

mobsf_url = ENV["MOBSF_URL"]
target = ENV["TARGET_PATH"]
min_security_score = ENV["MIN_SECURITY_SCORE"].to_i
max_cvss_score = ENV["MAX_CVSS_SCORE"].to_f

puts "Starting to scan \"#{target}\""

begin 
  uri = URI.parse("#{mobsf_url}api/v1/upload")
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "12345"

  file_part = ""
  File.open(target, 'rb') do |f|
    file_part = Part.new :name => 'file',
                :body => f,
                :filename => target,
                :content_type => 'application/octet-stream'
  end

  boundary = "---------------------------#{rand(10000000000000000000)}"
  body = MultipartBody.new [file_part], boundary

  request.body = body.to_s
  request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"

  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end

  if (response.code.to_i > 299)
    p "MobSF reques failed for unknown reason, status code: #{response.code}, body: #{response.body}"
    exit 1
  end

  puts "File uploaded, requesting a scan"

  scan_details = JSON.parse(response.body)

  uri = URI.parse("#{mobsf_url}api/v1/scan")
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "12345"
  request.set_form_data(
    "file_name" => scan_details["file_name"],
    "hash" => scan_details["hash"],
    "scan_type" => scan_details["scan_type"],
  )

  scan_response = Net::HTTP.start(uri.hostname, uri.port, :read_timeout => 600) do |http|
    http.request(request)
  end

  if (scan_response.code.to_i > 299)
    p "MobSF reques failed for unknown reason, status code: #{scan_response.code}, body: #{scan_response.body}"
    exit 1
  end

rescue SocketError => e
  puts "MobSF request failed due to network error: #{e}"
  exit 1
rescue Exception => e  
  puts "MobSF request failed due to unknwon error #{e}"
  exit 1
end

scan_result = JSON.parse(scan_response.body)
security_score = scan_result["appsec"]["security_score"].to_i
cvss = scan_result["average_cvss"].to_f

puts "Security score: #{security_score}, expected at least: #{min_security_score}"
puts "CVSS score: #{cvss}, expected at most: #{max_cvss_score}"

# Save PDF report
uri = URI.parse("#{mobsf_url}api/v1/download_pdf")
request = Net::HTTP::Post.new(uri)
request["Authorization"] = "12345"
request.set_form_data(
  "hash" => scan_details["hash"]
)

pdf_response = Net::HTTP.start(uri.hostname, uri.port, :read_timeout => 600) do |http|
  http.request(request)
end


open("output/#{scan_details["file_name"]}.pdf", 'w') { |f|
  f.puts pdf_response.body
}

if ((security_score < min_security_score) or (cvss > max_cvss_score))
  puts "MobSF: too low safety analysis result." 
  puts "Security score: #{security_score}, the result must be at least: #{min_security_score}"
  puts "CVSS score: #{cvss}, the result must be less than: #{max_cvss_score}"
  exit 1
end

puts "Scan completed - a valid safety analysis result has been obtained"
