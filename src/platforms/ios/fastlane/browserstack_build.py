import argparse
import json
import os
import sys
from time import time, sleep
from browserstack.local import Local # Run 'pip install browserstack-local' if missing

import requests
from requests.adapters import HTTPAdapter
from requests.auth import HTTPBasicAuth
from requests.packages.urllib3.util.retry import Retry
from typing import List

XCUI_BUILD_TIMEOUT_SECONDS = 60 * 60
XCUI_FAILED_STATUS = ('failed', 'error')
XCUI_SUCCESS_STATUS = 'passed'
BROWSERSTACK_API_URL = 'https://api-cloud.browserstack.com/app-automate'


def _browserstack_xcui_upload_file(url, user, access_key, file_path):
    with open(file_path, 'rb') as file:
        return _browserstack_post(url, user, access_key, files={'file': file})


def _browserstack_get(url, user, access_key, params=None, data=None, raise_for_status=True):
    auth = HTTPBasicAuth(user, access_key)
    response = _gen_session().get(url, auth=auth, params=params, data=data)
    return _browserstack_api_response(response, raise_for_status)


def _browserstack_post(url, user, access_key, files=None, params=None, json_data=None, raise_for_status=True):
    auth = HTTPBasicAuth(user, access_key)
    response = _gen_session().post(url, auth=auth, files=files, params=params, json=json_data)
    return _browserstack_api_response(response, raise_for_status)


def _browserstack_api_response(response, should_raise_for_status=True):
    print(f'response.text: {response.text}')
    if should_raise_for_status:
        response.raise_for_status()
    return response.status_code, json.loads(response.text)


def _gen_session():
    session = requests.Session()
    retry = Retry(connect=3, backoff_factor=0.5)
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('http://', adapter)
    session.mount('https://', adapter)
    return session


def _get_command_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--device', type=str, dest='browserstack_device', required=True)
    parser.add_argument('--user', type=str, dest='browserstack_user', required=True)
    parser.add_argument('--access-key', type=str, dest='browserstack_access_key', required=True)
    parser.add_argument('--app-file', type=str, dest='app_file', required=True)
    parser.add_argument('--tests-file', type=str, dest='tests_file', required=True)
    parser.add_argument('--local-key', type=str, dest='local_key', required=False)

    return parser.parse_args()


def _validate_parameters(args):
    if not args.app_file:
        ValueError('APP file path is empty')

    if not args.tests_file:
        ValueError('Tests file path is empty')

    if not args.browserstack_device:
        ValueError('Browserstack device is empty')


def _wait_for_xcui_build(user, access_key, build_id: str):
    start = time()
    while True:
        _, response = _browserstack_get(
            url=f'{BROWSERSTACK_API_URL}/xcuitest/v2/builds/{build_id}',
            user=user,
            access_key=access_key,
        )
        xcui_build_status = response['status']
        print(f'XCUI build: {build_id} status: {xcui_build_status}')

        if xcui_build_status in XCUI_FAILED_STATUS:
            raise RuntimeError(f'XCUI build: {build_id} failed with status: {xcui_build_status}')
        elif xcui_build_status == XCUI_SUCCESS_STATUS:
            break

        if time() - start > XCUI_BUILD_TIMEOUT_SECONDS:
            raise TimeoutError(f'XCUI build: {build_id} timeout: {XCUI_BUILD_TIMEOUT_SECONDS}s')

        sleep(15)

    return response


def main():
    args = _get_command_args()
    print('Browserstack XCUI build')

    print(f'browserstack-device: {args.browserstack_device}')
    print(f'app-file: {args.app_file}')
    print(f'tests-file: {args.tests_file}')
    print('Validate parameters')
    _validate_parameters(args)

    print(f'Upload file: {args.app_file} to browserstack')
    _, response = _browserstack_xcui_upload_file(
        url=f'{BROWSERSTACK_API_URL}/xcuitest/v2/app',
        user=args.browserstack_user,
        access_key=args.browserstack_access_key,
        file_path=args.app_file
    )
    app_url = response['app_url']

    print(f'Upload file: {args.tests_file} to browserstack')
    _, response = _browserstack_xcui_upload_file(
        url=f'{BROWSERSTACK_API_URL}/xcuitest/v2/test-suite',
        user=args.browserstack_user,
        access_key=args.browserstack_access_key,
        file_path=args.tests_file
    )
    test_url = response['test_suite_url']

    print(f'Trigger new build with ipa: {app_url} and tests: {test_url}')
    bs_local = None
    # check if local_key exists and has value
    if args.local_key is not None:
        # creates an instance of Local
        bs_local = Local()
        bs_local_args = { "key": args.local_key }
        #starts the Local instance with the required arguments
        bs_local.start(**bs_local_args)

        #check if BrowserStack local instance is running
        print(f'Runnig BrowserStack Local: {bs_local.isRunning()}')

        _, response = _browserstack_post(
            url=f'{BROWSERSTACK_API_URL}/xcuitest/v2/build',
            user=args.browserstack_user,
            access_key=args.browserstack_access_key,
            json_data={
                'devices': args.browserstack_device.split(', '),
                'app': app_url,
                'deviceLogs': True,
                'testSuite': test_url,
                'coverage': True,
                'browserstack.local' : 'true'
            })
    else:
        _, response = _browserstack_post(
            url=f'{BROWSERSTACK_API_URL}/xcuitest/v2/build',
            user=args.browserstack_user,
            access_key=args.browserstack_access_key,
            json_data={
                'devices': args.browserstack_device.split(', '),
                'app': app_url,
                'deviceLogs': True,
                'testSuite': test_url,
                'coverage': True
            })

    xcui_build_id = response['build_id']
    xcui_build_url = f'https://app-automate.browserstack.com/dashboard/v2/builds/{xcui_build_id}'

    print(f'Waiting for xcui build: {xcui_build_url} to finish ...')
    _wait_for_xcui_build(
        user=args.browserstack_user,
        access_key=args.browserstack_access_key,
        build_id=xcui_build_id
    )
    if bs_local is not None:
        bs_local.stop()

    print(f'Browserstack xcui build: {xcui_build_url} finished successfully')


if __name__ == '__main__':
    main()
