"""Read an immutable exclusion prefix for a new continuation epoch.

This is not a reader for resuming the current output file: it discards the
in-memory exclusion certificates. The new epoch must reference the complete
original checkpoint by hash and exclude the entire imported prefix when
writing its own suffix. Original certificates remain the replay authority.
"""
from pathlib import Path
import hashlib
import json


def checkpoint_hash(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        while block := stream.read(1 << 20):
            digest.update(block)
    return digest.hexdigest()


def exclusion_box(record):
    # This record shape belongs to excluded leaves in the qualified schema.
    # Decode/discard one certificate at a time instead of retaining all trees.
    if 'Box' in record and 'PValueUpper' in record:
        return dict(Box=record['Box'])
    return record


def read_prefix_index(path, ancestors=()):
    path = Path(path)
    assert path.resolve() not in ancestors, 'Cyclic checkpoint reference'
    with path.open(encoding='utf-8') as stream:
        state = json.load(stream, object_hook=exclusion_box)
    assert all(set(row) == {'Box'} for row in state['Excluded'])
    prefix = state.get('ExcludedPrefixSource')
    if prefix is not None:
        parent = Path(prefix['Path'])
        assert type(prefix['Count']) is int and prefix['Count'] >= 0
        assert checkpoint_hash(parent) == prefix['SHA256'], 'Checkpoint parent changed'
        prior = read_prefix_index(parent, ancestors + (path.resolve(),))
        assert len(prior['Excluded']) == prefix['Count'], 'Checkpoint prefix length changed'
        state['Excluded'] = prior['Excluded'] + state['Excluded']
    return state
