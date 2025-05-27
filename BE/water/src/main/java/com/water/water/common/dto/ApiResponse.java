package com.water.water.common.dto;

import com.water.water.common.ResponseCode;
import com.water.water.common.ResponseMessage;
import lombok.Builder;
import lombok.Data;

@Builder
@Data
public class ApiResponse<T> {
    @Builder.Default
    private String status = ResponseCode.SUCCESS;
    @Builder.Default
    private String message = ResponseMessage.SUCCESS;
    private T data;
}
