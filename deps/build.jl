using NodeJS

function install_deps()
  io = IOBuffer();
  cmd = Cmd(`$(npm_cmd()) install "db-hafas"`)
  run(pipeline(cmd, stdout=io))
  @info String(take!(io))
end

function patch()
  io = IOBuffer();
  cmd = Cmd(`$(nodejs_cmd().exec[1]) -e "var path = require.resolve('hafas-client'); console.log(path)"`)
  run(pipeline(cmd, stdout=io))
  hafas_client_path = String(take!(io))
  hafas_dir = Base.Filesystem.dirname(hafas_client_path)
  patchfile = Base.Filesystem.joinpath(hafas_dir, "p/db/index.js")

  # replace the line
  # req.cfg = {...req.cfg, rtMode: 'REALTIME'}
  # with
  # req.cfg = {...req.cfg, rtMode: 'HYBRID'}
  s = read(patchfile, String)
  if contains(s, "REALTIME")
    @info "REALTIME found, replacing it with HYBRID"
    write(patchfile, replace(s, "REALTIME" => "HYBRID"));
  elseif contains(s, "HYBRID")
    @info "HYBRID found, skip"
  else
    error("Didn't find HYBRID or REALTIME. Something went wrong.")
  end
end

install_deps()
patch()
