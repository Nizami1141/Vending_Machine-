`timescale 1ns / 1ps

module vending_machine(clk, en, rst, nickel, dime, quarter, dispense, collect, amount, inserted, next_inserted);
    input rst, en; // Reset and enable signals
    input clk;
    input nickel, dime, quarter; // Coin inputs
    output dispense, collect; // Drink dispense and collect signals
    reg dispense, collect;
    output [3:0] amount; // Amount in multiples of 5 cents
    output [6:0] inserted; // Current inserted value
    output [6:0] next_inserted; // Next inserted value
    reg [3:0] amount;
    reg [6:0] inserted;
    reg [6:0] next_inserted;

    //////////////////////////////////////////////////////////////////
    // State (inserted) register logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            inserted <= 7'd0;
        end else begin
            inserted <= next_inserted; // Update the state (inserted) for every clock cycle
        end
    end

    //////////////////////////////////////////////////////////////////
    // Next state (next_inserted) logic
    always @(nickel or dime or quarter or en or rst or inserted) begin
        if (rst) begin
            next_inserted = 7'd0;
        end else if (en) begin
            next_inserted = inserted; // Default to current state
            case (inserted)
                7'd0: begin
                    if (nickel) next_inserted = 7'd5;
                    if (dime) next_inserted = 7'd10;
                    if (quarter) next_inserted = 7'd25;
                end
                7'd5: begin
                    if (nickel) next_inserted = 7'd10;
                    if (dime) next_inserted = 7'd15;
                    if (quarter) next_inserted = 7'd30;
                end
                7'd10: begin
                    if (nickel) next_inserted = 7'd15;
                    if (dime) next_inserted = 7'd20;
                    if (quarter) next_inserted = 7'd35;
                end
                7'd15: begin
                    if (nickel) next_inserted = 7'd20;
                    if (dime) next_inserted = 7'd25;
                    if (quarter) next_inserted = 7'd40;
                end
                7'd20: begin
                    if (nickel) next_inserted = 7'd25;
                    if (dime) next_inserted = 7'd30;
                    if (quarter) next_inserted = 7'd45;
                end
                7'd25: begin
                    if (nickel) next_inserted = 7'd30;
                    if (dime) next_inserted = 7'd35;
                    if (quarter) next_inserted = 7'd50;
                end
                default: next_inserted = inserted; // Stay in the current state
            endcase
        end else begin
            next_inserted = inserted; // No change if not enabled
        end
    end

    //////////////////////////////////////////////////////////////////
    // Output logic
    always @(inserted or rst) begin
        if (rst) begin
            collect = 1'b0;
            dispense = 1'b0;
            amount = 4'd0;
        end else begin
            case (inserted)
                7'd30: begin
                    dispense = 1'b1; // Dispense the drink
                    collect = 1'b0;
                    amount = 4'd6;
                end
                7'd35: begin
                    dispense = 1'b1;
                    collect = 1'b1; // Collect signal for change
                    amount = 4'd7;
                end
                7'd40: begin
                    dispense = 1'b1;
                    collect = 1'b1;
                    amount = 4'd8;
                end
                7'd50: begin
                    dispense = 1'b1;
                    collect = 1'b1;
                    amount = 4'd10; // Max change
                end
                default: begin
                    dispense = 1'b0;
                    collect = 1'b0;
                    amount = inserted / 5; // Display amount in multiples of 5
                end
            endcase
        end
    end

endmodule
