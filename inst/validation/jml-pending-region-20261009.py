"""Restrict a frozen subdivision worker to one pending rectangle and its children.

Build a new source epoch; never edit source files bound to retained evidence.
Selecting work does not change a bound, exclusion rule or unresolved decision.
"""
from fractions import Fraction as Q
import inspect


def selected_pending_index(pending, parent):
    if parent is None:
        return len(pending)-1 if pending else None
    parent = list(map(Q, parent))
    if len(parent) != 4 or not (0 < parent[0] < parent[2] and 0 < parent[1] < parent[3]):
        raise ValueError('Selected parent must be a positive rectangle')
    selected = None
    for index, encoded in enumerate(pending):
        box = list(map(Q, encoded))
        if len(box) != 4 or not (0 < box[0] < box[2] and 0 < box[1] < box[3]):
            raise ValueError('Pending leaf must be a positive rectangle')
        overlap = all(max(box[k], parent[k]) < min(box[k+2], parent[k+2]) for k in (0, 1))
        inside = all(parent[k] <= box[k] and box[k+2] <= parent[k+2] for k in (0, 1))
        if overlap and not inside:
            raise ValueError('Selected parent cuts an existing pending leaf')
        if inside:
            selected = index
    return selected


def scope_worker(source):
    """Change only the argument/identity/queue selection in the retained worker."""
    changes = [
        ('def run(root, psi, destination, steps, checks=False, ',
         inspect.getsource(selected_pending_index)+'\n\ndef run(root, psi, destination, steps, checks=False, '),
        ('profile_only=False, witness_cache=None, geometry=None, retained_duals=None):',
         'profile_only=False, witness_cache=None, geometry=None, retained_duals=None, pending_parent=None):'),
        ("    identity = dict(ExecutableSource=str(Path(__file__)), CheckpointEncoding='json-excluded-prefix-v1',",
         "    if pending_parent is not None:\n"
         "        assert all(initial[k] <= pending_parent[k] < pending_parent[k+2] <= initial[k+2] for k in (0, 1))\n"
         "    identity = dict(ExecutableSource=str(Path(__file__)), CheckpointEncoding='json-excluded-prefix-v1',\n"
         "                    SelectedPendingParent=None if pending_parent is None else list(map(str, pending_parent)),"),
        ("        if not state['Pending']: break\n"
         "        encoded = state['Pending'].pop(); box = list(map(Q, encoded)); lower, upper = bounds(box)",
         "        selected = selected_pending_index(state['Pending'], pending_parent)\n"
         "        if selected is None: break\n"
         "        encoded = state['Pending'].pop(selected); box = list(map(Q, encoded)); lower, upper = bounds(box)"),
        ("    parser.add_argument('--steps', type=int, default=100)",
         "    parser.add_argument('--steps', type=int, default=100)\n"
         "    parser.add_argument('--pending-parent', type=Q, nargs=4,\n"
         "                        help='Process only this pending rectangle and its descendants')"),
        ('    assert args.psi != 0 and args.steps > 0',
         '    assert args.psi != 0 and args.steps > 0\n'
         '    assert args.pending_parent is None or (args.reuse is not None and args.pending_only)'),
        ('args.profile_only, args.witness_cache, args.geometry, args.retained_duals)',
         'args.profile_only, args.witness_cache, args.geometry, args.retained_duals, args.pending_parent)'),
    ]
    for before, after in changes:
        if source.count(before) != 1:
            raise ValueError('Frozen worker does not match the reviewed queue contract')
        source = source.replace(before, after, 1)
    return source


if __name__ == '__main__':
    from pathlib import Path
    import sys
    import ast
    source, destination = map(Path, sys.argv[1:])
    candidate = scope_worker(source.read_text())
    ast.parse(candidate)
    with destination.open('x') as stream:
        stream.write(candidate)
