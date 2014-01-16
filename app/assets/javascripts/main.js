window.bb = window.bb || {};

window.bb.humanize_channels = function (channels) {
    return parseInt(channels) === 0 ? 'Video' : 'Audio';
};

window.bb.humanize_profile = function (profile) {
    switch (parseInt(profile)) {
        case 1:
            return '320x240, 120Kbit';
        case 2:
            return '360x270, 200Kbit';
        case 3:
            return '640x480, 400Kbit';
        case 4:
            return '720x540, 600Kbit';
        case 101:
            return 'AAC, 32Kbit, mono';
        case 102:
            return 'AAC, 48Kbit, mono';
        case 103:
            return 'AAC, 96Kbit, stereo';
        default:
            return profile;
    }
};
