`timescale 1ns / 1ps

module aes_encrypt_tb;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [127:0] plaintext;
    reg [127:0] key;

    // Outputs
    wire [127:0] ciphertext;
    wire done;

    // Instantiate the AES Encryption Unit Under Test (UUT)
    aes_encrypt uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .plaintext(plaintext),
        .key(key),
        .ciphertext(ciphertext),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        start = 0;
        plaintext = 128'h00112233445566778899aabbccddeeff;
        key =       128'h000102030405060708090a0b0c0d0e0f;

        // Apply reset
        #20;
        rst = 0;

        // Start AES encryption
        #10;
        start = 1;
        #10;
        start = 0;

        // Wait for encryption to complete
        wait(done == 1);

        // Display result
        $display("Ciphertext: %h", ciphertext);
        $finish;
    end
endmodule