package com.water.water.db.repository;

import com.water.water.db.entity.MemberFishingPoint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MemberFishingPointRepository extends JpaRepository<MemberFishingPoint, Long> {
}
