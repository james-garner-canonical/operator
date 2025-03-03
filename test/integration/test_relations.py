# Copyright 2025 Canonical Ltd.
from __future__ import annotations

import json

import jubilant
import pytest

CHARM = 'basic'
MODEL = f'{CHARM}-model'
UNIT = f'{CHARM}/0'


@pytest.fixture(scope='module')
def juju():
    j = jubilant.Juju()
    j.add_model(MODEL)
    try:
        j.deploy(
            './test/integration/basic_charm/basic_ubuntu-22.04-amd64.charm',
            resource={'container-image': 'ubuntu:latest'},
        )
        j.wait(jubilant.all_active)
        yield j
    finally:
        j.destroy_model(MODEL)


def get_relation_data(juju: jubilant.Juju) -> dict[str, str]:
    args = ('run', UNIT, 'basic-action', '--format=json')
    return json.loads(json.loads(juju.cli(*args))[UNIT]['results']['get'].replace("'", '"'))


def set_relation_data(juju: jubilant.Juju, data: dict[str, str]) -> dict[str, str]:
    args = ('run', UNIT, 'basic-action', '--format=json', f"data='{json.dumps(data)}'")
    return json.loads(json.loads(juju.cli(*args))[UNIT]['results']['set'].replace("'", '"'))


def test_assign_relation_data(juju: jubilant.Juju):
    data = {'foo': 'bar', 'baz': 'bartholemew'}
    new = set_relation_data(juju, data)
    print(new)
    assert new == data
    double_check = get_relation_data(juju)
    assert double_check == data
