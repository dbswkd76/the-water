package com.water.water.db.entity;

import java.io.Serializable;
import java.util.Objects;

public class MemberFishingPointId implements Serializable {
    private Long memberId;
    private Long fishingPointId;

    public MemberFishingPointId() {
    }
    public MemberFishingPointId(Long fishingPointId, Long memberId) {
        this.fishingPointId = fishingPointId;
        this.memberId = memberId;
    }
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if(!(o instanceof MemberFishingPointId)) return false;
        MemberFishingPointId that = (MemberFishingPointId) o;
        return Objects.equals(fishingPointId, that.fishingPointId) &&
                Objects.equals(memberId, that.memberId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(fishingPointId, memberId);
    }
}
