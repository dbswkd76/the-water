package com.water.water.guide.controller;

import com.water.water.common.dto.ApiResponse;
import com.water.water.guide.dto.Guide;
import com.water.water.guide.service.GuideService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequestMapping("/api")
@RequiredArgsConstructor
@RestController
public class GuideController {
    public final GuideService guideService;

    @GetMapping("/guide")
    public ApiResponse<Guide> getGuide() {
        Guide response=new Guide(1L, "Api Guide","example");
        guideService.tryCatchGuide();
        return ApiResponse.<Guide>builder()
                .data(response)
                .build();
    }


}
