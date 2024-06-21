| [↩️ Back](./) |
| --- |

# ZABBIX INSTALLATION STEPS

It is advisable to plan ahead when deploying Zabbix in a production environment, and [the official documentation](https://www.zabbix.com/documentation/current/en) is always the main reference for concepts and procedures.

To help plan the environment, these are common steps to achieve a stable Zabbix monitoring environment. They are not in any particular order, but rather a logical progression from one step to the next from a requirements perspective.

<BR>

---

| **Status**         | **Activity**                                     | **Remark\*** |
| :---:              | ---                                              | :--- |
| 📅                 | **Documentation**                                | _This repository_ |
|                    | ✅ Document the project                          | ⚠️ **Always** |
| <BR> | | |                                                            
| 📅                 | **Plan the environment**                         | |
|                    | 💡 _Business overview_                           | |
|                    | 💡 _Map technologies_                            | |
|                    | 💡 _Define the objective and expectations_       | |
|                    | 💡 _Define and share responsabilities_           | |
|                    | 💡 _Define the architecture_                     | |
|                    | 💡 _Define the schedule_                         | |
| <BR> | | |
| 📅                 | [**Zabbix installation steps**](https://www.zabbix.com/documentation/current/en/manual/installation/getting_zabbix) | |
|                    | ✅ Deploy server(s)                              | |
|                    | ✅ Server access                                 | `ssh user@host` |
|                    | ✅ Management server access                      | `sudo -i` |
|                    | ✅ Server update                                 | `dnf upgrade -y --refresh` |
|                    | ✅ [Timezone configuration](https://www.freedesktop.org/software/systemd/man/latest/timedatectl.html) | `timedatectl set-timezone [TIMEZONE]` |
|                    | ✅ Date and time syncronization                  | `dnf install chrony` |
|                    | ✅ Repository installation                       | |
|                    | ✅ DBMS deployment                               | |
|                    | ✅ [Minimum DBMS security configuration](https://dev.mysql.com/doc/mysql-secure-deployment-guide/8.0/en/) | `mysql_secure_installation` |
|                    | ✅ Advanced DBMS security configuration          | _ask the DBA_ |
|                    | ✅ [Zabbix database creation](https://www.zabbix.com/documentation/current/en/manual/appendix/install/db_scripts) | |
|                    | ✅ Zabbix database user creation                 | _Different user for each Zabbix component_ |
|                    | ✅ Zabbix Server installation                    | |
|                    | ✅ Zabbix Server configuration                   | |
|                    | ✅ Zabbix Frontend installation                  | |
|                    | ✅ Zabbix Frontend configuration                 | |
|                    | ✅ Zabbix Proxy installation                     | |
|                    | ✅ Zabbix Proxy configuration                    | |
|                    | ✅ Zabbix Agent localhost installation           | _To all Zabbix servers_ |
|                    | ✅ [Secure the setup](https://www.zabbix.com/documentation/current/en/manual/installation/requirements/best_practices) | |
|                    | ✅ [Local access configuration](https://www.zabbix.com/documentation/current/en/manual/config/users_and_usergroups) | |
|                    | ✅ [Domain access configuration](https://www.zabbix.com/documentation/current/en/manual/web_interface/frontend_sections/users/authentication) | _LDAP_ |
|                    | ✅ Custom DNS name                               | _DNS server_ |
|                    | ✅ Frontend SSL certificate deployment           | |
|                    | ✅ [Super admin user definition](https://www.zabbix.com/documentation/current/en/manual/config/users_and_usergroups/permissions) | _Define those responsible_ |
|                    | ✅ [Initial template customization](https://www.zabbix.com/documentation/current/en/manual/config/templates) | |
|                    | ✅ Zabbix Agent metadata definition              | |
|                    | ✅ [Autoregistration rule creation](https://www.zabbix.com/documentation/current/en/manual/config/notifications/action) | |
|                    | ✅ [Custom midia setup](https://www.zabbix.com/documentation/current/en/manual/web_interface/frontend_sections/alerts/mediatypes) | |
| <BR> | | |
| 📅 | [**Initial dashboard**](https://www.zabbix.com/documentation/current/en/manual/web_interface/frontend_sections/dashboards) | |
|                    | ✅ Update the Zabbix Server dashboard            | |
|                    | ✅ Monitor the Zabbix DBMS                       | |
|                    | ✅ Monitor the Zabbix Frontend                   | |
| <BR> | | |
| 📅                 | **Maintenance instructions and host deployment** | |
|                    | ✅ [Zabbix Agent installation guide](https://www.zabbix.com/documentation/current/en/manual/concepts/agent) | _Agent 2 prefered_ |
|                    | ✅ [Zabbix Agent Autoregistration guide](https://www.zabbix.com/documentation/current/en/manual/discovery/auto_registration) | |
|                    | ✅ Train operators and users                     | |
| <BR> | | |
| 📅                 | **Monitoring environment**                       | |
|                    | ⏳ Build the monitoring environment              | |

---

✅ - Finished \
⏳ - Ongoing \
📅 - Planned

---

> **\* A small or brief note that may vary depending on the environment.**

<BR>

| [⬆️ Top](#zabbix-installation-steps) |
| --- |