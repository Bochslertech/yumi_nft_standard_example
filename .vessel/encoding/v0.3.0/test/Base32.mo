import Base32 "../src/Base32";

assert (
    Base32.encode([102, 111, 111, 0, 98, 97, 114]) 
    == [77, 90, 88, 87, 54, 65, 68, 67, 77, 70, 90, 65]
); // "foo bar"
