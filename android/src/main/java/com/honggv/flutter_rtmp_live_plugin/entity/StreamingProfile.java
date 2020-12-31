package com.honggv.flutter_rtmp_live_plugin.entity;

public class StreamingProfile {

    private String publishUrl;
    private String videoQuality;
    private String audioQuality;
    private boolean quicEnable;

    public String getPublishUrl() {
        return publishUrl;
    }

    public void setPublishUrl(String publishUrl) {
        this.publishUrl = publishUrl;
    }

    public String getVideoQuality() {
        return videoQuality;
    }

    public void setVideoQuality(String videoQuality) {
        this.videoQuality = videoQuality;
    }

    public String getAudioQuality() {
        return audioQuality;
    }

    public void setAudioQuality(String audioQuality) {
        this.audioQuality = audioQuality;
    }

    public boolean isQuicEnable() {
        return quicEnable;
    }

    public void setQuicEnable(boolean quicEnable) {
        this.quicEnable = quicEnable;
    }
}
