module dac8830(
    input  wire         sys_clk,
    input  wire         sys_rst,
    input  wire         delay_en,
    input  wire [15:0]  dac_data1,   // 通道1数据
    output wire         spi_sclk,
    output wire         spi_cs1,
    output wire         spi_mosi
);

localparam DELAY_1US    = (1_000 / 10) - 1;
localparam CYCLE_COUNT  = (16 * 2) - 1;

reg         sclk;
reg         cs;
reg         mosi;
reg [23:0]  delay_cnt;
reg [4:0]   cycle_cnt;
reg [15:0]  spi_data;
reg [15:0]  send_data;
reg [3:0]   state;

// 用于CS下降沿打拍处理
reg         cs_first;
reg         cs_second;
wire        cs_nege1;
wire        cs_nege2;

wire        update_data;

// 状态机生成数据
always @(posedge sys_clk or negedge sys_rst) begin
    if (!sys_rst) begin
        sclk      <= 1'b0;
        cs        <= 1'b1;
        send_data <= 16'd0;
        cycle_cnt <= 5'd0;
        delay_cnt <= 24'd0;
        state     <= 4'd0;
    end else begin
        case (state)
            4'd0: begin // IO初始化
                sclk      <= 1'b0;
                cs        <= 1'b1;
                send_data <= 16'd0;
                cycle_cnt <= 5'd0;
                if (delay_cnt >= DELAY_1US) begin
                    delay_cnt <= 24'd0;
                    state <= 4'd1;
                end else begin
                    delay_cnt <= delay_cnt + 1'b1;
                    state <= 4'd0;
                end
            end
            4'd1: begin // 接收通道1数据
                send_data <= dac_data1;
                if (delay_en)
                    state <= 4'd2;
                else
                    state <= 4'd1;
            end
            4'd2: begin // 保持CS高一段时间
                sclk      <= 1'b0;
                cs        <= 1'b1; // CS 高电平至少维持一定时间
                cycle_cnt <= 5'd0;
                if (delay_cnt >= 24'd2) begin
                    delay_cnt <= 24'd0;
                    state <= 4'd3;
                end else begin
                    delay_cnt <= delay_cnt + 1'b1;
                    state <= 4'd2;
                end
            end
            4'd3: begin // 拉低CS，准备数据传输
                cs <= 1'b0;
                sclk <= 1'b0;
                if (delay_cnt >= 24'd2) begin
                    delay_cnt <= 24'd0;
                    state <= 4'd4;
                end else begin
                    delay_cnt <= delay_cnt + 1'b1;
                    state <= 4'd3;
                end
            end
            4'd4: begin // 产生SPI SCLK时钟，并传输数据
                sclk <= ~sclk;
                if (cycle_cnt >= CYCLE_COUNT) begin
                    cycle_cnt <= 5'd0;
                    state <= 4'd1;
                end else begin
                    cycle_cnt <= cycle_cnt + 1'b1;
                    state <= 4'd4;
                end
            end
            default: state <= 4'd0;
        endcase
    end
end

// 对CS做下降沿打拍
always @(posedge sys_clk or negedge sys_rst) begin
    if (!sys_rst) begin
        cs_first   <= 1'b0;
        cs_second  <= 1'b0;
    end else begin
        cs_first  <= cs;
        cs_second <= cs_first;
    end
end

assign cs_nege1 = (!cs) & cs_first;
assign cs_nege2 = (!cs_first) & cs_second;

assign update_data = sclk | cs_nege2;

// SPI数据传输逻辑：芯片在SCLK下降沿传输数据
always @(negedge update_data or negedge sys_rst or posedge cs_nege1) begin
    if (!sys_rst) begin
        mosi      <= 1'b0;
        spi_data  <= 16'd0;
    end else if (cs_nege1) begin
        mosi      <= 1'b0;
        spi_data  <= send_data;
    end else begin
        mosi      <= spi_data[15];
        spi_data  <= {spi_data[14:0], 1'b0};
    end
end

assign spi_sclk = sclk;
assign spi_cs1  = cs;
assign spi_mosi = mosi;

endmodule
