# Lab 2 — Introduction to JSON and YAML
In this lab, you will look at different types of variables, and learn how they are represented in JSON and YAML. Ansible uses JSON internally to represent the data passed to and from modules. YAML is used as the format for input to Ansible, i.e., Playbooks and Inventories.

## Variable types
In Ansible there are three types of variables commonly used. Scalar variables (simple variables) hold a single value, usually a string. Lists and Dictionaries can hold multiple values at the same time. 

The difference between Lists and Dictionaries is in how you access the value you want.  In a list, the values are accessed by a numerical index, for example first, second, third, etc. In a Dictionary, the values are accessed by name.

### Lists
Examples of working with Lists in YAML and JSON.
YAML list
```yaml
list_a: [ "hello", "world"]
```
The square brackets indicate a list, and then each value is provided in a comma separated list.

There is an alternative way to represent lists in YAML that is often easier to read, especially in longer lists. 
```yaml
list_a:
  - "hello"
  - "world"
```
You may add as many values as needed.  

Note the indentation and the use of hyphens. The indentation is not just to make things easy to read, it is an important part of YAML. The indentation level tells Ansible how things are grouped together. Everything indented at the same level under “list\_a” is grouped together as part of “list\_a”.

We can create more complex data structures, for example a list of lists.
```yaml
list_of_lists:
  - [ "a-first_list_first_value", "b-first_list_second_value" ]
  - [ "c-second_list_first_value", "d-second_list_second_value" ]
```
A more compact version of the example above, the names of the values have been shorted to keep it easy to read.
```yaml
list_of_lists: [ ["a","b"], ["c","d"] ]
```
Finally, the most verbose version of this example.
```yaml
list_of_lists:
  - - "a"
    - "b"
  - - "c"
    - "d"
```

There are excellent free websites that offer YAML validation. You simply paste your YAML file into the website, and it will verify the file and help you to correct any errors in syntax. Of course, sensitive data should never be entered into these websites, it is best used as a learning tool.

[YAML Lint](https://www.yamllint.com "YAML Lint website")

In JSON, lists are represented very similarly, however instead of using indentation to represent groupings curly braces ‘{‘ and ‘}’ are used. JSON calls these arrays, but Ansible and YAML call them lists. To be consistent with Ansible this document will call them lists.

The example below recreates the list of lists example from the previous page.
```yaml
list_of_lists: [ ["a","b"], ["c", "d"] ]
```
The syntax is identical to the first YAML example. This is not by accident, JSON files are also valid YAML files. YAML is a superset of JSON.

How do you access values from a list?
Look at the example YAML file below.
```yaml
list_travel:
  - "Denver"
  - "New York"
  - "London"
```

This list represents someone’s travel plans for the summer. The first stop is Denver, then New York, and finally London. In Ansible, like almost all programming languages, we start counting from zero, not one. 

```yaml
list_travel[0] == "Denver"
list_travel[1] == "New York"
list_travel[2] == "London"
```

In later labs you will see many more examples of this.

### Dictionaries
Dictionaries work almost exactly like Lists, the only difference is that instead of indexing the values by a number, we index by an arbitrary string. 

Suppose we wanted to make a list of pets and what kind of animal they are. Given the name of a pet, we want to know if they are a dog, a cat, or a horse.

We can do that in YAML like this:
```yaml
pets: 
  ranger: dog
  aspen: dog
  maple: horse
  willow: cat
```

We call the index into the dictionary the key. The format is always “key: value” with the key on the left and the value on the right, with a colon for the separator. 

How would we access the pets dictionary to find out what kind of animal aspen is?

```yaml
pets["aspen"] == "dog"
```

Dictionaries can be nested just like lists. 
```yaml
pets:
  aspen: { "gender":"female", "color":"black" }
  ranger: { "gender":"male", "color","brown" }
```

Another way to write this using indentation instead of curly braces is shown below.
```yaml
pets:
  aspen:
    gender: female
    color: black
  ranger:
    gender: male
    color: brown
```
### String quoting in YAML
The previous example didn’t use quotes for the values in the dictionary. Most of the examples before then used quotes around strings. In YAML values are always strings, so if you don’t quote your string it will usually work. There is a corner case where the YAML parser will fail to understand your string properly. For example:
```yaml
pets:
  aspen: {{ gender['aspen'] }}
```

The curly braces in this example are from a templating language called Jinja that Ansible uses internally. Jinja is introduced in later labs. For now just note that the double curly braces are used to invoke Jinja.

Why does this example fail? We are really trying to create a string with Jinja, but Ansible’s YAML parser can’t tell if we are calling Jinja or creating a nested dictionary.  When in doubt, add quotes!

The correct way to write this example would be:
```yaml
pets:
  aspen: "{{ gender['aspen'] }}"
```

Finally, a quick example of dictionaries in JSON.
```yaml
pets = { "aspen":"dog", "ranger":"dog", "willow":"cat", "maple":"horse" }
```
A dictionary is represented as a list of key value pairs surrounded by curly braces.

## Ansible Inventory group and host variables
In Lab 1 you looked at the inventory file called routers. The ansible environment you are using has been configured to use the directory “inventory” for all inventory objects. 

Within that directory are a few special sub-directories, named “host\_vars” and “group\_vars”. 

Login to the lab environment and cd into the lab2 directory.
Run the tree command, as shown in the output below.
```yaml
(Lab) ➜  lab2 tree
.
├── ansible.cfg
├── ansible.cfg.no_defaults
└── inventory
    ├── group_vars
    │   ├── cisco.yml
    │   └── juniper.yml
    ├── host_vars
    │   ├── r1.yml
    │   └── r2.yml
    └── routers

4 directories, 7 files
(Lab) ➜  lab2
```

The tree command nicely displays all of the files and subdirectories, by default from the current working directory. You can also do things like “tree \<some path\>” to see the tree starting from the specified path.

Under the inventory directory, you see two sub-directories host\_vars and group\_vars. These directories have special properties.

### Host\_vars
Inside the host\_vars directory you can define additional variables for a given host. The format of the files are “ansible\_host\_name.yml”. So any variables defined in the file “r1.yml” are automatically associated with the host named r1. 

It is critical to be careful with case on the file name. On some systems like Linux the file system is case sensitive. macOS is by default not case sensitive. If the case in the inventory file doesn’t match the case in the file name the variables will not be associated. Developing on a Mac and deploying on Linux is a great way to learn this lesson, the hard way.

Take a look at the r1 and r2 host variables.
```yaml
(Lab) ➜  lab2 cd inventory
(Lab) ➜  inventory cat host_vars/r1.yml
---
ansible_host: 172.20.20.10
(Lab) ➜  inventory cat host_vars/r2.yml
---
ansible_host: 172.20.20.11
(Lab) ➜  inventory
```

The variable ansible\_host defines the hostname or IP address used to contact that host. Your IP addresses will be different depending on which student account you are using.

### Group\_vars
The group\_vars directory works the same way as the host\_vars directory, but the variables are defined at the group level instead of the host level.

All hosts that belong to a group will inherit the variables defined for that group. This is a very convenient way to specify variables that are in common for many hosts. In this lab, the Juniper and Cisco devices each need different variables defined in order to make connectivity work.

Take a look at the cisco and juniper group variables.
```yaml
(Lab) ➜  inventory cat group_vars/cisco.yml
---
ansible_connection: ansible.netcommon.network_cli
ansible_network_os: cisco.ios.ios
ansible_user: admin
ansible_password: admin
(Lab) ➜  inventory cat group_vars/juniper.yml
---
ansible_connection: ansible.netcommon.netconf
ansible_network_os: junipernetworks.junos.junos
ansible_user: admin
ansible_password: admin@123
(Lab) ➜  inventory
```

All the variables here are specific to Ansible’s connection to the Cisco and Juniper devices. 

The ansible\_connection variable defines the method used for communication with the device. Cisco IOS uses the standard Cisco CLI over SSH, whereas Juniper devices run Netconf over SSH.

The ansible\_network\_os variable defines the type of device to interact with. 

Finally, the ansible\_user and ansible\_password define the SSH username and password used to access the device. You can also use SSH public keys and SSH agents to access the devices, but that is out of scope for this lab. 