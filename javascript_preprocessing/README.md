| [↩️ Back](../) |
| --- |

# JAVASCRIPT PREPROCESSING

Often Zabbix items gather data that is unprepared for processing or it is simply "_dirty_". Therefore, it is important to prepare the data to make it suitable for further processing and ultimately for exploration and visualization.

After the data is collected, we can clean it with Zabbix preprocessing steps and one such step is the [custom JavaScript script](https://www.zabbix.com/documentation/current/en/manual/config/items/preprocessing/javascript).
Unfortunately, Zabbix does not support Python for processing, nor Shell. So, we are stuck with JavaScript. But thit is not a bad thing, though. Zabbix JavaScript is implemented using the [Duktape](https://duktape.org) JavaScript engine and provides [additional Zabbix objects](https://www.zabbix.com/documentation/current/en/manual/config/items/preprocessing/javascript/javascript_objects). You may have to resort to old methods or unconventional ways to handle the input data, though.

Keep in mind that JavaScript preprocessing uses a function body and the input value is always a string.
> _JavaScript preprocessing is done by invoking JavaScript function with a single parameter 'value' and user provided function body. The preprocessing step result is the value returned from this function (...)._

<BR>

## INDEX

- [JavaScript Add Property](./javascript_add_property.md)
- [JavaScript Remove Property](./javascript_remove_property.md)
