using DBHafas

using TimeZones
using Dates

@info j = journeys(
  8070003, 8000244, date=ZonedDateTime(now(), tz"Europe/Warsaw")
)
@info l = locations("Aachen")
