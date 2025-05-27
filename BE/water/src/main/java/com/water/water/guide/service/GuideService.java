package com.water.water.guide.service;

import com.water.water.common.exception.BadRequestException;
import com.water.water.guide.dto.Guide;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GuideService {
    public void tryCatchGuide(){
        try{
            //service logic
        }catch(Exception e){
            throw new BadRequestException("잘못된 요청입니다");
        }

    }
}
