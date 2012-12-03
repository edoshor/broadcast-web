module GlobalConstants

  TRANSCODER_HOST = '10.65.6.104'
  TRANSCODER_PORT = 10000

  PRESETS = {
      preset1: {force: true, tracks_cnt: 2, tracks: [1,101]},
      preset2: {force: true, tracks_cnt: 2, tracks: [1,101]},
      preset3: {force: true, tracks_cnt: 2, tracks: [1,101]}
  }

  SOURCES = {
      source1: {ip1: 'ip1', port1: 9000, ip2: 'ip2', port2: 9001, tracks_cnt: 2, tracks: [0,1]},
      source2: {ip1: 'ip1', port1: 9000, ip2: 'ip2', port2: 9001, tracks_cnt: 2, tracks: [0,1]},
      source3: {ip1: 'ip1', port1: 9000, ip2: 'ip2', port2: 9001, tracks_cnt: 2, tracks: [0,1]}
  }
end