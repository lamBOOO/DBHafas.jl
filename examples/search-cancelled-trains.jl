using DBHafas

using Dates
using TimeZones

# l = locations.(["Berlin","Aachen","Frankfurt Fern", "Frankfurt main", "Köln", "Stuttgart", "Stuttgart Uni", "München"], opt=Dict(:results=>1))
# map(lo->(lo[1]["id"], lo[1]["name"]), l)
locs = [
 ("8011160", "Berlin Hbf")
 ("8000001", "Aachen Hbf")
 ("8070003", "Frankfurt(M) Flughafen Fernbf")
 ("8000105", "Frankfurt(Main)Hbf")
 ("8096022", "KÖLN")
 ("8000096", "Stuttgart Hbf")
 ("8006513", "Stuttgart Universität")
 ("8000261", "München Hbf")
]
ids = parse.(Int, map(l->l[1],locs))
date = ZonedDateTime(now() - Dates.Minute(120), tz"Europe/Warsaw")
# date = ZonedDateTime(DateTime(2023,5,12,10,0,0,0), tz"Europe/Warsaw")

function print_cancelled(js)
  for j in js["journeys"]
    for l in j["legs"]
      if haskey(l, "cancelled")
        println(
          "CANCELLED: ",
          l["plannedDeparture"], " | ", l["line"]["name"], " | ",
          l["origin"]["name"], " ---> ", l["destination"]["name"]
        )
      end
    end
  end
end

function get_cancelled_legs(js)
  res = []
  for j in js["journeys"]
    for l in j["legs"]
      if haskey(l, "cancelled")
        push!(res, l)
      end
    end
  end
  return res
end

function print_legs(legs)
  for l in legs
    if haskey(l, "cancelled")
      println(
        l["plannedDeparture"], " | ", l["line"]["name"], " | ",
        l["origin"]["name"], " ---> ", l["destination"]["name"]
      )
    end
  end
end

all_legs_c = []
for (from, to) in Iterators.product(ids, ids)
  if from != to
    from_station = locs[findfirst(x->x[1]==string(from), locs)][2]
    to_station = locs[findfirst(x->x[1]==string(to), locs)][2]
    @info from_station, to_station
    js = journeys(from, to, date=date)
    legs_c = get_cancelled_legs(js)
    if length(legs_c) > 0
      push!(all_legs_c, legs_c...)
      print_legs(legs_c)
    end
  end
end
println("--- UNIQUE SUMMARY ---")
print_legs(sort(unique(x->x["line"]["name"]*x["plannedDeparture"], all_legs_c), by=x->x["origin"]["name"]))
