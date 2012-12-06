module GlobalConstants

  TRANSCODER_HOST = '10.65.6.104'
  TRANSCODER_PORT = 10000

  SOURCES = {
      source1: {ip1: '192.168.1.2', port1: 3000, ip2: '192.168.1.2', port2: 3000},
      source2: {ip1: '192.168.1.2', port1: 3001, ip2: '192.168.1.2', port2: 3001},
      source3: {ip1: '192.168.1.2', port1: 3002, ip2: '192.168.1.2', port2: 3002},
      source4: {ip1: '192.168.1.2', port1: 3003, ip2: '192.168.1.2', port2: 3003}
  }

  PRESETS = {
      preset1: {id:1, force: 1, tracks_cnt: 2, tracks: [[1, 0, 0, 0],
                                                  [101, 1, 10, 0]]},
      preset2: {id:2, force: 1, tracks_cnt: 2, tracks: [[2, 0, 0, 0],
                                                  [102, 1, 10, 0]]},
      preset3: {id:3, force: 1, tracks_cnt: 2, tracks: [[3, 0, 0, 0],
                                                  [102, 1, 10, 0]]},
      preset4: {id:4, force: 1, tracks_cnt: 2, tracks: [[4, 0, 0, 0],
                                                  [103, 1, 10, 0]]},
      tv66_1: {id:5, force: 1, tracks_cnt: 7, tracks: [[1, 0, 0, 0],
                                                 [101, 1, 10, 0],
                                                 [2, 0, 0, 0],
                                                 [3, 0, 0, 0],
                                                 [102, 1 ,10, 0],
                                                 [101, 1, 10, 0],
                                                 [102, 1, 10, 0]]},
      tvrus_1 => {id:6, force: 1, tracks_cnt: 5, tracks: [[1, 0, 0, 0],
                                                       [101, 1, 10, 0],
                                                       [2, 0, 0, 0],
                                                       [3, 0, 0, 0],
                                                       [102, 1 ,10, 0]]},
      live_1 => {id:7, force: 1, tracks_cnt: 17, tracks: [[1, 0, 0, 0],
                                                          [101, 1, 10, 0],
                                                          [2, 0, 0, 0],
                                                          [3, 0, 0, 0],
                                                          [102, 1 ,10, 0],
                                                          [101, 1 ,10, 0],
                                                          [102, 1 ,10, 0],
                                                          [101, 1 ,10, 0],
                                                          [102, 1 ,10, 0],
                                                          [101, 1 ,10, 0],
                                                          [102, 1 ,10, 0],
                                                          [101, 1 ,10, 0],
                                                          [102, 1 ,10, 0],
                                                          [101, 1 ,10, 0],
                                                          [102, 1 ,10, 0],
                                                          [101, 1 ,10, 0],
                                                          [102, 1 ,10, 0]]}
  }

  PRESETS_AUDIO_CHANNELS = {
      1 => {tracks_cnt: 2, tracks: [0, 1]},
      2 => {tracks_cnt: 2, tracks: [0, 1]},
      3 => {tracks_cnt: 2, tracks: [0, 1]},
      4 => {tracks_cnt: 2, tracks: [0, 1]},
      5 => {tracks_cnt: 7, tracks: [0, 1, 0, 0, 1, 2, 2]},
      6 => {tracks_cnt: 5, tracks: [0, 1, 0, 0, 1]},
      7 => {tracks_cnt: 17, tracks: [0, 1, 0, 0, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]}
  }

end