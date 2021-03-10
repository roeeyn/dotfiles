#!/usr/bin/env python3
# YOU NEED TO ENABLE FULL DISK ACCESS FOR THE /usr/sbin/cron
# System Preferences -> Security & Privacy -> Privacy -> Full Disk Access
# CMD + SHIFT + G to look up for the file
import os

SHARED_CALENDARS = {
    # "mlh": "https://calendar.google.com/calendar/embed?src=majorleaguehacking.com_pr3njjh4ok0pi93jfqm51jg2g0%40group.calendar.google.com&ctz=America%2FMexico_City",
    # "pandas_course": "https://calendar.google.com/calendar/embed?src=c_qi9d6gdtjubr40rgojl1hq7qtg%40group.calendar.google.com&ctz=America%2FMexico_City",
}

PERSONAL_CALENDARS = {
    # "work": "https://calendar.google.com/calendar/ical/rodrigo.medina%40konfio.mx/private-ec56fe24e10affc07caf2f2db064f57c/basic.ics",
    "personal": "https://calendar.google.com/calendar/ical/rodrigo.medina.neri%40gmail.com/private-e2c461d0c1fb1764cebf5966d2db5835/basic.ics",
}


def notify(title, text):
    os.system(
        """
        osascript -e 'display notification "{}" with title "{}"'
        """.format(
            text, title
        )
    )


# notify("Sync Started", "Calendar sync finished succesfully")


def parse_shared_calendar(calendar):
    source = calendar.split("src=")[1].split("&")[0]
    return f"https://calendar.google.com/calendar/ical/{source}/public/basic.ics"


parsed_shared_calendars = {
    description: parse_shared_calendar(calendar)
    for description, calendar in SHARED_CALENDARS.items()
}

all_calendars = {**parsed_shared_calendars, **PERSONAL_CALENDARS}

for calendar_name, calendar_url in all_calendars.items():
    os.system(
        f"/usr/local/bin/wget -O $HOME/org/calendars/{calendar_name}.ics {calendar_url}"
    )
    os.system(
        f"/usr/local/bin/ical2orgpy $HOME/org/calendars/{calendar_name}.ics $HOME/org/calendars/{calendar_name}.org"
    )
    os.system(f"rm $HOME/org/calendars/{calendar_name}.ics")

# notify("Sync Finished", "Calendar sync finished succesfully")
