| [↩️ Back](./) |
| --- |

# DIRECTORY FILE SIZE LISTING

It [has been noted](https://www.zabbix.com/forum/zabbix-help/486606-flexible-template-for-monitoring-multiple-files) that some Zabbix users need to monitor multiple files from the file systems of their monitored hosts. This is not difficult in itself, as it is possible to create a template with Macros and assign it to a host. However, it can happen that you need to monitor several files in different directories on a system.

It would be nice if this could be handled by a discovery rule with its corresponding item prototypes, similar to the discovery of Windows services.

At first glance, you might think that their are no possible keys to find multiple files that span to multiple directories. After all, the `vfs.file.get` item key can only handle one file, and `vfs.dir.get` can only traverse one directory, which in principle makes sense. But note that "_traverse_" is the key word. `vfs.dir.get` can traverse a directory. So the higher up you go in a filesystem tree, the broader you can traverse.

<BR>

| [⬆️ Top](#directory-file-size-listing) |
| --- |
