module DBHafas

using Dates
using JSON
using NodeJS
using TimeZones

export journeys

function journeys(from::Integer, to::Integer; date=Dates.now())
  io = IOBuffer();
  nodejscmd =
  """
  import {createDbHafas} from 'db-hafas';
  let hafas = createDbHafas('test@test.com')
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

end # module DBHafas
