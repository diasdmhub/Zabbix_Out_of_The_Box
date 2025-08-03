| [↩️ Back](./) |
| --- |

# ZABBIX GOOD PRACTICES

Below are some good Zabbix practices that encompass general tips, strategies or techniques to make Zabbix environment more efficient, clear, and organized for day-to-day use. This compilation includes [Zabbix's own "best practices"][best_practices] as well as other good practices.

<BR>

---

| Practice | Remarks|
| :---     | :---   |
| Make sure [Zabbix definitions][zabbix_def] are well known for operators | Template, host, item, trigger, groups, event, etc. | |
| Standardize names for hosts, groups, templates, and other entities | Name standards are very important for an optimal search of hosts, groups and other elements. Filters are often used to search for data in Zabbix, and standard names help users to find the correct entity or value. External systems integrated with Zabbix (_e.g. Grafana_) can also benefit from an intelligent naming scheme. |
| [Use templates][use_templates] as much as possible and avoid direct host configurations | |
| Don't forget to use mass updates when dealing with multiple entities | Mass updates are useful for quickly updating the configurations of multiple templates, hosts, items, triggers, etc. |
| Use [master and dependent items][dependent_items] | This minimizes requests to monitored entity. |
| Configure items with [custom intervals][custom_intervals] | Items can collect data only when it is necessary, which helps save storage space. This can also help to ignore data fluctuations when it is insignificant. |
| Watch for very low data collection intervals | Frequent data queries can burden the network environment and the objects being monitored, as well as fill the DB with unnecessary data. |
| Build triggers with [coherent severities][trigger_severities] (run from `Disaster` for everything) | Severities can serve as a visual cue indicating the level of priority an event may have. |
| Use dashboards that help to visualize what really matters | Effective information sharing relies on good visual data presentation. When building dashboards, organize the data and consider the target audience so the dashboard can communicate relevant information first. Avoid overcrowding the dashboard with excessive data. Nesting [dashboards into pages][dashboards_pages] or tabs can be a more effective and [visually appealing][d3_gallery] alternative. |
| Create dashboards with the same visual language | Diverse communication of data can lead to diverse interpretation, which can create inconsistencies and misunderstandings. |
| Configure dashboards and [widgets refresh interval][refresh_interval] according to the item interval | If an item is updated only once every 10 minutes, there is no need to update the dashboard every 30 seconds. This can reduce the load on the frontend and DB, especially when multiple dashboards are open. |
| Configure [trigger dependencies][trigger_depend] to prevent cascading events or actions | |
| Regularly revise and clean inactive items, triggers, and hosts | Avoid too many unsupported items or hosts with failed connections. |
| Use [Zabbix Proxies][zabbix_proxies] for distributed environments | |
| Integrate notification channels and customize messages | Don't rely solely on standard media messages. Create custom messages for different integrations and audiences. |
| [Harden Zabbix security][zabbix_access] | Secure the frontend and database as well. |
| Train teams and disseminate the monitoring and observability culture | Ensure that all participants have a clear understanding of the purpose and benefits of monitoring the environment, whether IT or business-related. |

<BR>

| [⬆️ Top](#zabbix-good-practices) |
| --- |

[best_practices]: https://www.zabbix.com/documentation/current/en/manual/best_practices/configuration
[zabbix_def]: https://www.zabbix.com/documentation/current/en/manual/definitions
[use_templates]: https://www.zabbix.com/documentation/current/en/manual/config/templates
[dependent_items]: https://www.zabbix.com/documentation/current/en/manual/config/items/itemtypes/dependent_items
[refresh_interval]: https://www.zabbix.com/documentation/current/en/manual/web_interface/frontend_sections/dashboards/widgets
[trigger_severities]: https://www.zabbix.com/documentation/current/en/manual/config/triggers/severity
[zabbix_proxies]: https://www.zabbix.com/documentation/current/en/manual/distributed_monitoring/proxies
[zabbix_access]: https://www.zabbix.com/documentation/current/en/manual/best_practices/security/access_control
[d3_gallery]: https://observablehq.com/@d3/gallery
[dashboards_pages]: https://www.zabbix.com/documentation/current/en/manual/web_interface/frontend_sections/dashboards
[trigger_depend]: https://www.zabbix.com/documentation/current/en/manual/config/triggers/dependencies
[custom_intervals]: https://www.zabbix.com/documentation/current/en/manual/config/items/item/custom_intervals
