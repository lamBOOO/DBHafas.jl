using DBHafas

using Dates
using TimeZones

j = journeys(8070003, 8000244, date=ZonedDateTime(DateTime(2023,5,15,10,0,0,0), tz"Europe/Warsaw"))
# j = DBPrices.journeys(8070003, 8000244, date=ZonedDateTime(DateTime(2023,5,11,20,0,0,0), tz"Europe/Warsaw"))
# j = DBPrices.journeys(8000096, 8000001, date=ZonedDateTime(DateTime(2023,5,11,20,0,0,0), tz"Europe/Warsaw"))  # stu -> ac
# j = DBPrices.journeys(8000096, 8000261, date=ZonedDateTime(DateTime(2023,5,11,20,0,0,0), tz"Europe/Warsaw"))

@info "NEW"
for j in j["journeys"]
  for l in j["legs"]
    if haskey(l, "cancelled")
      @info l["cancelled"]
      display(l)
    end
  end
end
