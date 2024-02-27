| [↩️ Back](../) |
| --- |

# AGGREGATE CALCULATIONS

It is possible to calculate data from several Zabbix items by using the ["aggregate functions"](https://www.zabbix.com/documentation/current/en/manual/appendix/functions/aggregate). These calculations are performed in the Zabbix Server itself and do not require an agent running on the monitored host.

It is an ["aggregate calculation"](https://www.zabbix.com/documentation/current/en/manual/config/items/itemtypes/calculated/aggregate) when a function is used to retrieve aggregates or list several items for aggregation. This function can work with history items or with ["foreach" functions](https://www.zabbix.com/documentation/current/en/manual/appendix/functions/aggregate/foreach) that return an array of values from filter parameters.

Aggregate calculations are very useful when you need to calculate a value that is beyond the scope of a single item. It can also be useful for measuring the behavior of a multi-host system. Another possible scenario is to aggregate serveral items from the same host to observe or calculate the overall behavior of that host.

In summary, comparing and creating statistics from multiple aggregated items can help observe a system or environment to proactively make it more resilient, as well as help to evaluate behaviors and trends.

<BR>

## INDEX

- [Count unique strings from items](./count_unique_strings_items.md)
