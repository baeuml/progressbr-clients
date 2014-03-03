"""
Python client for the progressbr web service.
"""
import os
import logging
import json
import requests


logger = logging.getLogger(__name__)


class RESTException(Exception):
    def __init__(self, status_code, *args):
        super(RESTException, self).__init__(*args)
        self.status_code = status_code


class ProgressbrClient:
    def __init__(self, base_url="https://progressbr.herokuapp.com"):
        self._base_url = base_url + '/api'
        if not self._base_url.startswith('http'):
            self._base_url = 'https://' + self._base_url

    def create(self, range_min=0, range_max=None, description=None, private_key=None):
        url = "%s/progress" % self._base_url
        headers = {'Content-Type': 'application/json' }

        if private_key is None:
            private_key = os.environ.get('PBR_PRIVATE_KEY', None)
        if private_key is not None:
            headers['Authorization'] = 'PBR %s' % private_key

        data = {}
        if range_min is not None:
            data['range_min'] = range_min
        if range_max is not None:
            data['range_max'] = range_max
        if description is not None:
            data['description'] = description

        r = requests.post(url, json.dumps(data), headers=headers)
        logger.debug('response headers: %s', r.headers)
        logger.debug('response content: %s', r.content)

        if r.status_code == 201:
            return json.loads(r.content)

        # else
        raise RESTException(r.status_code, r.content)

    def update(self, uuid, n_min=None, n_max=None, description=None):
        url = "%s/progressupdate" % self._base_url
        headers = {'Content-Type': 'application/json' }

        data = {
            'progress_id': uuid,
            }
        if n_min is not None:
            data['n_min'] = n_min
        if n_max is not None:
            data['n_max'] = n_max
        if description is not None:
            data['description'] = description

        r = requests.post(url, json.dumps(data), headers=headers)
        if r.status_code == 201:
            return json.loads(r.content)

        # else
        raise RESTException(r.status_code, r.content)


## shortcut methods with default client

def create(*args, **kwargs):
    client = ProgressbrClient()
    return client.create(*args, **kwargs)


def update(*args, **kwargs):
    client = ProgressbrClient()
    return client.update(*args, **kwargs)
