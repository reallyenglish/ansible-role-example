Table of Contents
=================

  * [Jinja2 Basics](#jinja2-basics)
  * [Variables](#variables)
  * [Loops](#loops)
    * [list](#list)
    * [dict](#dict)
      * [Do something with a pair of key and value in a dict](#do-something-with-a-pair-of-key-and-value-in-a-dict)
      * [Do somthing with keys in a dict](#do-somthing-with-keys-in-a-dict)
  * [Conditional](#conditional)
    * [Simple if](#simple-if)
    * [if ... else ...](#if--else-)
    * [case ... when ...](#case--when-)
  * [See if a key exists in a dict](#see-if-a-key-exists-in-a-dict)
  * [Merging two dict variables](#merging-two-dict-variables)
  * [Creating filters and tests](#creating-filters-and-tests)

# Jinja2 Basics

Jinja2 is the template engine of ansible. Honestly, I am not a fun of it. [The
documentation](http://jinja.pocoo.org/docs/dev/templates/) is sometimes cryptic
and does not clearly explain what you should know. Here is a list of what you
should know about jinja2 to write ansible roles and plays.

# Variables

In a template, you have access to all ansible variables. In rare cases, you
need to create variables in a template. In those cases, remember that variables
declared in a template have no scope, meaning the variables are always in
global scope in the template. Use `set` to declare a variable in a template.

    {% set foo = 'bar' %}
    {% if something is defined %}
    {% set foo = 'baz' %} # NOT local to the `if` scope
    {% endif %}
    {{ foo }}

The both of `foo` is same variable. If `something` is defined, the result is
`baz`, which might not be what you expect.

# Loops


## list

    {% set l = [ 'foo', 'bar' ] %}
    {% for i in l %}
    {{ i }}
    {% endfor %}

## dict

### Do something with a pair of key and value in a dict

    {% set d = { 'foo': 1, 'bar': 2 } %}
    {% for k, v in d %}
    {{ k }} = {{ v }}
    {% endfor %}


But in almost all cases, you would need `dictsort` because a dict is not
ordered, which breaks idempotentcy.

    {% set d = { 'foo': 1, 'bar': 2 } %}
    {% for k, v in d | dictsort %}
    {{ k }} = {{ v }}
    {% endfor %}

### Do something with keys in a dict

If you are not interested in values, simply use `for`.

    {% for key in d | dictsort %}
    key == {{ key }}
    {% endfor %}

# Conditional

## Simple if

    {% if foo is defined %}
    foo is defined
    {% endif %}

## if ... else ...

It's `elif`, not `elseif` or `elsif`..

    {% if foo is defined %}
    foo is defined
    {% elif %}
    foo is not defined
    {% endif %}

## case ... when ...

No, jinja2 does not have `case`. Use `if ... elif ... elif ... endif `.


# See if a key exists in a dict

    {% if 'the_key' in a_dict %}
    ... do something ...
    {% endif %}

This is often used in tasks. The following example runs command when a dict, `bar\_dict` has `foo` in the keys.

    - command: /path/to/command
      when: "{{ 'foo' in bar_dict }}"

# Merging two dict variables

 `ansible` 2.0 and later implements
[combine](https://docs.ansible.com/ansible/playbooks_filters.html#combining-hashes-dictionaries),
which is useful to override keys when missing. See [how it is used in a
role](https://github.com/reallyenglish/ansible-role-isakmpd/commit/09e7586a3e8e3685e1ff55337bbd80249a49ed0a#diff-6b014b4ae903f6b65327e49caaad3227R8),
which overrides missing keys..

# Creating filters and tests

See [Extending_Ansible](Extending_Ansible)
