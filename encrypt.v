module aes_encrypt (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [127:0] plaintext,
    input wire [127:0] key,
    output reg [127:0] ciphertext,
    output reg done
);
    reg [3:0] round;
    reg [127:0] state;
    reg busy;

    wire [127:0] round_key;
    wire [127:0] sub_bytes_out;
    wire [127:0] shift_rows_out;
    wire [127:0] mix_columns_out;

    wire [1407:0] round_keys; // 11 round keys (11 * 128 bits)

    // Generate all round keys
    key_expansion key_exp (
        .key(key),
        .round_keys(round_keys)
    );

    assign round_key = round_keys[1407 - round*128 -: 128];

    // SubBytes
    sub_bytes sb (
        .in(state),
        .out(sub_bytes_out)
    );

    // ShiftRows
    shift_rows sr (
        .in(sub_bytes_out),
        .out(shift_rows_out)
    );

    // MixColumns (not used in round 10)
    mix_columns mc (
        .in(shift_rows_out),
        .out(mix_columns_out)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            round <= 0;
            done <= 0;
            busy <= 0;
            ciphertext <= 0;
            state <= 0;
        end else if (start && round == 0 && !busy) begin
            // Initial round (AddRoundKey)
            state <= plaintext ^ round_keys[1407 -: 128];
            round <= 1;
            done <= 0;
            busy <= 1;
        end else if (round < 10 && busy) begin
            // Rounds 1–9: SubBytes -> ShiftRows -> MixColumns -> AddRoundKey
            state <= mix_columns_out ^ round_keys[1407 - round*128 -: 128];
            round <= round + 1;
        end else if (round == 10 && busy) begin
            // Final round: SubBytes -> ShiftRows -> AddRoundKey (no MixColumns)
            ciphertext <= shift_rows_out ^ round_keys[1407 - 10*128 -: 128];
            done <= 1;
            round <= 0;
            busy <= 0;
        end
    end
endmodule
 