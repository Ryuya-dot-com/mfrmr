"""Queue regressions on the retained early-closing parent; no numerical refits."""
from pathlib import Path
from fractions import Fraction as Q
import ast
import copy
import json
import math
import runpy
import tempfile
import unittest
from unittest.mock import patch

helper = runpy.run_path('inst/validation/jml-pending-region-20261009.py')
select = helper['selected_pending_index']
root = Path('validation-results/mfrm-wide-map-pcm-r50-portable-20261003/summary-n30')
review = root/'normal-mc-calibration/profiles/normal-rescale'
trial = review/'left-profile-guided-subdivision-20261007/worker'
original = (trial/'source.py').read_text()
candidate = helper['scope_worker'](original)
parent = json.loads((review/'left-13over2-v7-retained-gap-diagnostic/point-review.json').read_text())['Parent']
seed = json.loads((review/'left-13over2-v7-retained-gap-diagnostic/setup/jml-left-13over2.json').read_text())
saved = json.loads((trial/'jml-left-13over2.json').read_text())
records = {tuple(row['Box']): row for row in saved['Excluded']}


def queue_loop(source):
    tree = ast.parse(source)
    run = next(node for node in tree.body if isinstance(node, ast.FunctionDef) and node.name == 'run')
    loop = next(node for node in run.body if isinstance(node, ast.For) and
                ast.unparse(node.iter) == 'range(steps)')
    numerical_start = next(i for i, node in enumerate(loop.body) if isinstance(node, ast.Assign) and
                           ast.unparse(node.targets[0]) == 'tail')
    decision = next(i for i, node in enumerate(loop.body) if isinstance(node, ast.If) and
                    ast.unparse(node.test) == 'excluded is not None')
    # Run the worker's actual queue/mutation/write loop, using retained outcomes
    # in place of numerical evaluation. The independent checker verifies bounds.
    loop.body[numerical_start:decision] = ast.parse('''
visited.append(encoded)
refine_profile = encoded == parent
excluded = None if refine_profile else copy.deepcopy(records[tuple(encoded)])
''').body
    return compile(ast.fix_missing_locations(ast.Module(body=[loop], type_ignores=[])), '<worker queue>', 'exec')


class PendingRegionTests(unittest.TestCase):
    def test_rectangle_selection_and_refusal(self):
        boxes = [['1', '1', '2', '2'], ['2', '1', '4', '2'], ['4', '1', '8', '2']]
        self.assertEqual(select(boxes, ['1', '1', '4', '2']), 1)
        self.assertEqual(select(boxes, None), 2)
        self.assertIsNone(select([], None))
        self.assertIsNone(select(boxes, ['8', '1', '9', '2']))
        self.assertEqual(select([['1/2', '1/3', '1', '2/3']], ['1/2', '1/3', '1', '2/3']), 0)
        for region in (['1', '1', '3', '2'], ['0', '1', '4', '2'], ['4', '1', '1', '2'], ['1']):
            with self.assertRaises(ValueError):
                select(boxes, region)
        with self.assertRaises(ValueError):
            select([['1', '1', '1', '2']], ['1', '1', '4', '2'])

    def run_loop(self, source, steps, state, selected):
        tree = ast.parse(source)
        numerical_helpers = [node for node in tree.body if isinstance(node, ast.FunctionDef) and
                             node.name in ('bounds', 'split')]
        env = dict(Q=Q, math=math, copy=copy, selected_pending_index=select,
                   state=state, steps=steps, pending_parent=selected, parent=parent,
                   records=records, visited=[], psi=Q(-13, 2), print=lambda *a, **k: None)
        exec(compile(ast.Module(body=numerical_helpers, type_ignores=[]), '<original geometry>', 'exec'), env)
        with tempfile.TemporaryDirectory() as directory:
            env['destination'] = Path(directory)/'checkpoint.json'
            env['write_checkpoint'] = lambda path, value: path.write_text(json.dumps(value))
            exec(queue_loop(source), env)
            if env['destination'].exists():
                self.assertEqual(json.loads(env['destination'].read_text()), state)
        return env['visited']

    def state(self):
        return dict(Pending=copy.deepcopy(seed['Pending']), Excluded=[],
                    Unresolved=copy.deepcopy(seed['Unresolved']), SplitCount=seed['SplitCount'], Complete=False)

    def test_actual_parent_stops_before_unrelated_work(self):
        state = self.state()
        self.assertEqual(len(self.run_loop(candidate, 7, state, list(map(Q, parent)))), 3)
        self.assertEqual(state['Pending'], seed['Pending'][:-1])
        self.assertEqual(state['Unresolved'], seed['Unresolved'])
        self.assertEqual(state['Excluded'], saved['Excluded'][:2])
        self.assertEqual(state['SplitCount'], seed['SplitCount']+1)
        self.assertFalse(state['Complete'])
        self.assertEqual(self.run_loop(candidate, 7, state, list(map(Q, parent))), [])

    def test_interrupted_scope_resumes_only_its_children(self):
        state = self.state()
        self.assertEqual(len(self.run_loop(candidate, 1, state, list(map(Q, parent)))), 1)
        state = json.loads(json.dumps(state))
        self.assertEqual(len(self.run_loop(candidate, 7, state, list(map(Q, parent)))), 2)
        self.assertEqual(state['Pending'], seed['Pending'][:-1])
        self.assertEqual(state['Excluded'], saved['Excluded'][:2])

    def test_unresolved_child_is_retained_without_claiming_completion(self):
        state = self.state()
        child = saved['Excluded'][0]['Box']
        with patch.dict(records, {tuple(child): None}):
            self.run_loop(candidate, 7, state, list(map(Q, parent)))
        self.assertEqual(state['Pending'], seed['Pending'][:-1])
        self.assertEqual(state['Unresolved'][:-1], seed['Unresolved'])
        self.assertEqual(state['Unresolved'][-1]['Box'], child)
        self.assertEqual(state['Excluded'], saved['Excluded'][1:2])
        self.assertFalse(state['Complete'])

    def test_original_failure_and_unscoped_behavior(self):
        prior, unchanged = self.state(), self.state()
        self.assertEqual(len(self.run_loop(original, 5, prior, None)), 5)
        self.assertEqual(len(self.run_loop(candidate, 5, unchanged, None)), 5)
        self.assertEqual(prior, unchanged)
        self.assertEqual(prior['Excluded'], saved['Excluded'])
        self.assertEqual(prior['Pending'], seed['Pending'][:-3])

    def test_numerical_functions_unchanged_and_wrong_source_refused(self):
        functions = lambda text: {n.name: ast.dump(n, include_attributes=False)
                                 for n in ast.parse(text).body if isinstance(n, ast.FunctionDef)}
        old, new = functions(original), functions(candidate)
        self.assertEqual(set(new)-set(old), {'selected_pending_index'})
        self.assertEqual({k: v for k, v in old.items() if k != 'run'},
                         {k: v for k, v in new.items() if k not in ('run', 'selected_pending_index')})
        with self.assertRaises(ValueError):
            helper['scope_worker'](candidate)


if __name__ == '__main__':
    unittest.main()
