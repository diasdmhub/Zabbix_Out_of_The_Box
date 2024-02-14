| [↩️ Back](../) |
| --- |

# ADD PROPERTIES INTO JSON OBJECTS

JSON data is perfect for creating dependent items. However, sometimes the raw JSON is unprepared for processing. So, JavaScript preprocessing can be used to add new values or manipulate object properties. This can have some advantages depending on your scenario.

<BR>

## Possible benefits

- [X] Manipulate data format;
- [X] Add new properties;
- [X] Calculate values before passing them to an LLD;
- [X] Avoid creating a calculated item.

<BR>

## Syntax
```javascript
var jsonValue = JSON.parse(value);
for (var i = 0; i < jsonValue.length; i++) {
  [newValue] = [codeLogic];
  jsonValue[i].[property] = [newValue];
}
return JSON.stringify(jsonValue);
```

This code is a simple yet effective way to add properties from JSON objects.
Remember to change the **`[newValue] = [codeLogic];`** to your own code logic and values. \
Where **`[property]`** is the new property (_key name_) to add into the JSON object, and **`[newValue]`** is the value of your new property.

<BR>

## Example

Consider a Zabbix item that collects a JSON array with properties that represent a process start time and end time.

> [!NOTE]
> The actual collected value is passed to the JavaScript preprocessing step as a textual string.

<BR>

### 1. Consider the sample value below.
> [!TIP]
> Avoid prettifying the data while testing it with Zabbix JavaScript.

```json
[
    {
    "endTime": "20240202101020",
    "startTime": "20240202101010"
    },
    {
    "endTime": "20240202101030",
    "startTime": "20240202101010"
    },
    {
    "endTime": "20240202100920",
    "startTime": "20240202101010"
    }
]
```

<BR>

**Zabbix passes the value as a string, i.e. the input value of the preprocessing step looks more like this:**
```json
[{"endTime":"20240202101020","startTime":"20240202101010"},{"endTime":"20240202101030","startTime":"20240202101010"},{"endTime":"20240202100920","startTime":"20240202101010"}]
```

![JSON raw string](./image/json_raw_string2.png)

<BR>

### 2. In this example, the `startTime` and `endTime` can be used to calculate the execution time for each process.

Notice that this JSON has several objects that represent a system process. The objects do not have an execution time property. Therefore, by using a JavaScript preprocessing step, we can calculate this execution time using the `startTime` and `endTime` strings and add this new value to the object.

#### Let's use the proposed code and add a few operations to accomplish this task.

```javascript
var regexStartTime = value.replace(/\"startTime\":\"(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})\"/g, "\"startTime\":\"$3-$2-$1 $4:$5:$6\"");
var regexEndTime   = regexStartTime.replace(/\"endTime\":\"(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})\"/g, "\"endTime\":\"$3-$2-$1 $4:$5:$6\"");

var jsonValue = JSON.parse(regexEndTime);
for (var i = 0; i < jsonValue.length; i++) {

  var startDate = new Date(jsonValue[i].startTime);
  var endDate   = new Date(jsonValue[i].endTime);

  var execTime = (endDate.getTime() - startDate.getTime()) / 1000;

  if (execTime < 0) { execTime = 0; }
  jsonValue[i].execTime = execTime;
}
return JSON.stringify(jsonValue);
```

![JavaScript code](./image/javascript_addkey_code.png)

<BR>

#### Here's what each piece of the code does:

a. The code starts by using regular expressions to manipulate the passed `value` string. It replaces occurrences of `startTime` and `endTime` into a more readable format. It goes from `YYYYMMDDHHmmss` to `YYYY-MM-DD HH:mm:ss`.

b. Next, the modified string (`regexEndTime`) is parsed into a JavaScript object using `JSON.parse()`. The resulting object is stored in the `jsonValue` variable.

c. A loop iterates through each element in `jsonValue`. \
For each element, it creates "_Date_" variables from the `startTime` and `endTime` values. Calculates the execution time (in seconds) as the difference between `endTime` and `startTime`. If the calculated `execTime` is negative, it sets it to `0`. Finally, the `execTime` property is added to the `jsonValue` variable.

d. The code returns the modified `jsonValue` object as a JSON string using `JSON.stringify()`.

<BR>

### 3. The resulting value is a JSON string with the `execTime` property.

```json
[
    {
    "endTime": "02-02-2024 10:10:20",
    "execTime": 10,
    "startTime": "02-02-2024 10:10:10"
    },
    {
    "endTime": "02-02-2024 10:10:30",
    "execTime": 20,
    "startTime": "02-02-2024 10:10:10"
    },
    {
    "endTime": "02-02-2024 10:09:20",
    "execTime": 0,
    "startTime": "02-02-2024 10:10:10"
    }
]
```

![Key removed from JSON](./image/json_key_added.png)

<BR>

| [⬆️ Top](#add-properties-into-json-objects) |
| --- |
