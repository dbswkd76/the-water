
package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.ResponseMessage;
import lombok.Builder;
import lombok.Data;
@Builder
@Data
public class ApiResponse<T> {
    @Builder.Default
    private String status = ResponseStatus.SUCCESS;
    @Builder.Default
    private String message = ResponseMessage.SUCCESS;
    private T data;
}