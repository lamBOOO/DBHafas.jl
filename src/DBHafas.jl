module DBHafas

using Dates
using JSON
using NodeJS
using TimeZones

export journeys, locations

DEF_USERAGENT = "test@testt.com"

function journeys(from::Integer, to::Integer; date=Dates.now())
  io = IOBuffer();
  nodejscmd =
  """
  import {createClient} from 'hafas-client'
  import {profile as dbProfile} from 'hafas-client/p/db/index.js'
  import {withRetrying} from 'hafas-client/retry.js'
  const retryingDbProfile = withRetrying(dbProfile, {
    retries: 5,
    minTimeout: 2 * 1000,
    factor: 1
  })
  let hafas = createClient(dbProfile, '$(DEF_USERAGENT)')
  // console.log('client created')
  hafas.journeys('$(from)', '$(to)', {
    results: 20,
    departure: new Date('$(string(date))'),
    remarks: true
  }).then((val)=>{
    console.log(JSON.stringify(val))
  })
  """
  cmd = Cmd(`$(nodejs_cmd().exec[1]) --input-type=module -e "$(nodejscmd)"`
  )
  run(pipeline(cmd, stdout=io))
  str = String(take!(io))
  res = JSON.parse(str)
  return res
end

# see:
# https://github.com/public-transport/hafas-client/blob/master/docs/locations.md
DEF_OPT_LOCATIONS = Dict(
	  :fuzzy =>        true # find only exact matches?
	, :results =>      5 # how many search results?
	, :stops =>        true # return stops/stations?
	, :addresses =>    true
	, :poi =>          true # points of interest
	, :subStops =>     true # parse & expose sub-stops of stations?
	, :entrances =>    true # parse & expose entrances of stops/stations?
	, :linesOfStops => false # parse & expose lines at each stop/station?
	, :language =>     "en" # language to get results in
)

function locations(query::String; opt=DEF_OPT_LOCATIONS)
  io = IOBuffer();
  nodejscmd =
  """
  import {createDbHafas} from 'db-hafas';
  let hafas = createDbHafas('$(DEF_USERAGENT)')
  hafas.locations('$(query)', $(JSON.json(opt))).then((val)=>{
    console.log(JSON.stringify(val))
  })
  """
  cmd = Cmd(`$(nodejs_cmd().exec[1]) --input-type=module -e "$(nodejscmd)"`
  )
  run(pipeline(cmd, stdout=io))
  str = String(take!(io))
  res = JSON.parse(str)
  return res
end

end # module DBHafas
