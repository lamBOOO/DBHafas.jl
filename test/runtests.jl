using DBHafas

using TimeZones
using Dates

j = journeys(8070003, 8000244, date=ZonedDateTime(now(), tz"Europe/Warsaw"))
display(j)
