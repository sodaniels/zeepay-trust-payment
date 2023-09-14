import XCTest

class ZIPTestSuite: BaseTestCase {
    // MARK: Properties
    
    lazy var payByCardFormPage = PayByCardFormPage(application: self.app)
    lazy var mainPage = MainPage(application: self.app)
    lazy var zipPage = ZIPPage(application: self.app)
    let generalErrorMessage = "An error occurred"
    let successfulMessage = "The request has been successfully completed"
    
    // MARK: Tests
    
    func testDiscardZipPaymentForm() {
        mainPage.tapPerformAuthWithZip()
        zipPage.tapCancelButton()
        
        XCTAssertTrue(payByCardFormPage.isAlertDiplayed(with: generalErrorMessage),
                      "Alert with a message: '\(generalErrorMessage)' was not displayed.")
    }
    
    func testSuccessfulAuthWithZipRequest() {
        let mobileNumber = "7782589365"
        mainPage.tapPerformAuthWithZip()
        zipPage.type(phoneNumber: mobileNumber)
            .tapNextButton()
        // Sleep is added to wait till code is returned
        Thread.sleep(forTimeInterval: 10)
        // fetch the newest code
        let expectation = XCTestExpectation()
        var zipCode: String?
        getZipCode(number: mobileNumber) { code in
            expectation.fulfill()
            guard let code = code else {
                XCTFail("Error fetching ZIP code")
                return
            }
            zipCode = code
        }
        _ = XCTWaiter.wait(for: [expectation], timeout: 10)
        guard let code = zipCode else {
            XCTFail("Missing ZIP code")
            return
        }
        zipPage.type(verifyCode: code)
        Thread.sleep(forTimeInterval: 10)
        zipPage.tapConfirmPaymentButton()

        XCTAssertTrue(mainPage.isAlertDiplayed(with: successfulMessage),
                      "Alert with a message: '\(successfulMessage)' was not displayed.")
    }
}

extension ZIPTestSuite {
    struct ZIPCode: Decodable {
        let body: String
        let created: String
        let sent: String

        var createdAsDate: Date? {
            let dateFormatter = DateFormatter()
            let tempLocale = dateFormatter.locale // save locale temporarily
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            guard let date = dateFormatter.date(from: created) else { return nil }
            dateFormatter.locale = tempLocale // reset the locale
            return date
        }
    }

    func getZipCode(number: String, completion: @escaping (_ code: String?) -> Void) {
        guard let url = URL(string: "https://0hw6hlmlvj.execute-api.us-east-1.amazonaws.com/dev/ecd8b8af-81ae-42b5-a448-a63c97b4f6b5/numbers/+44\(number)") else {
            completion(nil)
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil else {
                completion(nil)
                return
            }
            guard let data = data, let codes = try? JSONDecoder().decode([ZIPCode].self, from: data),
                  let first = codes.filter({ $0.createdAsDate != nil }).sorted(by: { $0.createdAsDate! > $1.createdAsDate! }).first,
                  let code = first.body.replacingOccurrences(of: " ", with: "").split(separator: ":").last else {
                completion(nil)
                return
            }
            completion(String(code))
        }.resume()
    }
}
