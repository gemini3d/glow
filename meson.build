project('GLOW', 'fortran',
  version : '0.981',
  default_options : ['default_library=static', 'buildtype=release'])

fc = meson.get_compiler('fortran')
fargs_old = [fc.first_supported_argument(['/nowarn', '-nowarn', '-w']),
            fc.first_supported_argument(['-std=legacy'])]
#fargs_new = [fc.first_supported_argument(['/stand:f18', '-stand f18', '-std=f2018']),
#            fc.first_supported_argument(['/warn:declarations', '-warn declarations', '-Mdclchk', '-fimplicit-none'])


cglow_src = files('glow.f90', 'cglow.f90', 'fieldm.f', 'solzen.f90', 'ssflux.f90', 'rcolum.f90', 'qback.f90', 'etrans.f90', 'exsect.f', 'gchem.f90', 'bands.f90', 'ephoto.f90', 'egrid.f90', 'maxt.f90')
snoem_src = files('snoem.f90', 'snoemint.f90', 'geomag.f90')
utils_src = files('mzgrid.f90', 'conduct.f90', 'nrlmsise00.f', 'iri90.f')

cglow = library('cglow', cglow_src, snoem_src, utils_src, fortran_args : fargs_old)

glow_basic_exe = executable('glowbasic', 'glowbasic.f90', link_with: cglow)

test('GlowBasic', glow_basic_exe,
  args: ['basic.nml'],
  workdir: meson.current_source_dir(),
  timeout: 10)
