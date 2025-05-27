package com.water.water.common.handler;

import com.water.water.common.dto.ApiResponse;
import com.water.water.common.exception.BadRequestException;
import com.water.water.common.ResponseCode;
import com.water.water.common.ResponseMessage;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ControllerExceptionHandler {

    //BAD REQUEST
    @ExceptionHandler(BadRequestException.class)
    public ApiResponse<?> handleBadRequestException(BadRequestException e) {
        return ApiResponse.builder()
                .data(e.getMessage())
                .status(ResponseCode.BAD_REQUEST)
                .message(ResponseMessage.BAD_REQUEST)
                .build();
    }

    //이외의
    @ExceptionHandler(Exception.class)
    public ApiResponse<?> serverErrorHandler(Exception e) {
        e.printStackTrace();
        return ApiResponse.builder()
                .data(e.getMessage())
                .status(ResponseCode.SERVER_ERROR)
                .message(ResponseMessage.SERVER_ERROR)
                .build();
    }

}
