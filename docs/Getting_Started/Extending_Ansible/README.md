Table of Contents
=================

  * [Table of Contents](#table-of-contents)
  * [Filter plugin](#filter-plugin)
    * [Example](#example)
  * [Test plugin](#test-plugin)
    * [Example](#example-1)
  * [Action plugin](#action-plugin)
    * [Next step](#next-step)

# Filter plugin

You can create your own filter under `filter_plugins`.

## Example

[ansible-role-resolver/filter_plugins/predictable_shuffle.py](https://github.com/reallyenglish/ansible-role-resolver/blob/master/filter_plugins/predictable_shuffle.py)
has a filter.

```python
from ansible import errors
import hashlib
import itertools

def predictable_shuffle(array, key):
    ''' returns a predictable_shuffled list '''
    nameservers_permutation = list(itertools.permutations(array))
    number_of_permutation = len(nameservers_permutation)
    index = int(hashlib.sha256(key).hexdigest(), 16) % number_of_permutation
    return nameservers_permutation[index]

class FilterModule(object):
    ''' A filter to predictable_shuffle a list '''
    def filters(self):
        return {
            'predictable_shuffle' : predictable_shuffle,
        }
```

# Test plugin

You can create your own test plugins under `test_plugins`.

## Example

jinja2 2.7 or older does not have `equalto` test. To use the test in older
jinja, create `test_plugins/equalto.py`.


```python
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible import errors

def equalto(value, other):
    return bool(value == other)

class TestModule(object):
    ''' Ansible file jinja2 tests '''

    def tests(self):
        return {
            'equalto' : equalto,
        }
```

Now `equalto` test is available in the role.

# Action plugin

To create a module in a role, create an action plugin.

Register an action in `action_plugins`.

```python
# action_plugins/logrotate.py

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.plugins.action import ActionBase

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display
    display = Display()


# a wrapper action module for logrotate module
class ActionModule(ActionBase):

    def run(self, tmp=None, task_vars=None):
        if task_vars is None:
            task_vars = dict()

        result = super(ActionModule, self).run(tmp, task_vars)

        logrotate_conf_d = self._templar.template(task_vars['logrotate_conf_d'])
        display.vv("logrotate_conf_d: %s" % logrotate_conf_d)

        if not 'config_dir' in self._task.args:
            self._task.args['config_dir'] = logrotate_conf_d

        result.update(self._execute_module(module_name='logrotate', module_args=self._task.args, task_vars=task_vars))

        return result
```

Create the module in `library`, such as `library/logrotate.py`.
`ansible-role-logrotate` has an `logrotate` action and module.

See [Developing Modules](http://docs.ansible.com/ansible/developing_modules.html) for writing a module.

## Next step

There are some pitfalls that the author has encountered, and you might, as
well. See [Pitfalls](../Pitfalls).
