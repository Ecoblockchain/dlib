/*
Copyright (c) 2016 Timur Gafarov 

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

/**
 * Interfaces for implementing secret key algorithms.
 *
 * Copyright: Eugene Wissner 2016-.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Eugene Wissner
 */
module dlib.crypto.symmetric;

/**
 * Implemented by secret key algorithms.
 */
interface SymmetricCipher
{
    /**
     * Returns: Key length.
     */
    @property inout(uint) keyLength() inout const pure nothrow @safe @nogc;

    /**
     * Returns: Minimum key length.
     */
    @property inout(uint) minKeyLength() inout const pure nothrow @safe @nogc;

    /**
     * Returns: Maximum key length.
     */
    @property inout(uint) maxKeyLength() inout const pure nothrow @safe @nogc;

    /// Cipher direction.
    protected enum Direction : ushort
    {
        encryption,
        decryption,
    }

    /**
     * Params:
     *     key = Key.
     */
    @property void key(ubyte[] key) pure nothrow @safe @nogc
    in
    {
        assert(key.length >= minKeyLength);
        assert(key.length <= maxKeyLength);
    }
}

/**
 * Implemented by block ciphers.
 */
interface BlockCipher : SymmetricCipher
{
    /**
     * Returns: Block size.
     */
    @property inout(uint) blockSize() inout const pure nothrow @safe @nogc;

    /**
     * Encrypts a block.
     *
     * Params:
     *    plain  = Plain text, input.
     *    cipher = Cipher text, output.
     */
    void encrypt(in ubyte[] plain, ubyte[] cipher)
    in
    {
        assert(plain.length == blockSize);
        assert(cipher.length == blockSize);
    }

    /**
     * Decrypts a block.
     *
     * Params:
     *    cipher = Cipher text, input.
     *    plain  = Plain text, output.
     */
    void decrypt(in ubyte[] cipher, ubyte[] plain)
    in
    {
        assert(plain.length == blockSize);
        assert(cipher.length == blockSize);
    }
}

/**
 * Mixed in by algorithms with fixed block size.
 *
 * Params:
 *     N = Block size.
 */
mixin template FixedBlockSize(uint N)
    if (N != 0)
{
    private enum uint blockSize_ = N;

    /**
     * Returns: Fixed block size.
     */
    final @property inout(uint) blockSize() inout const pure nothrow @safe @nogc
    {
        return blockSize_;
    }
}

/**
 * Mixed in by symmetric algorithms.
 * If $(D_PARAM Min) equals $(D_PARAM Max) fixed key length is assumed.
 *
 * Params:
 *     Min = Minimum key length.
 *     Max = Maximum key length.
 */
mixin template KeyLength(uint Min, uint Max = Min)
    if (Min != 0 && Max != 0)
{
    static if (Min == Max)
    {
        private enum uint keyLength_ = Min;

        /**
         * Returns: Key length.
         */
        final @property inout(uint) keyLength() inout const pure nothrow @safe @nogc
        {
            return keyLength_;
        }

        /**
         * Returns: Minimum key length.
         */
        final @property inout(uint) minKeyLength() inout const pure nothrow @safe @nogc
        {
            return keyLength_;
        }

        /**
         * Returns: Maximum key length.
         */
        final @property inout(uint) maxKeyLength() inout const pure nothrow @safe @nogc
        {
            return keyLength_;
        }
    }
    else static if (Min < Max)
    {
        private enum uint minKeyLength_ = Min;
        private enum uint maxKeyLength_ = Max;

        /**
         * Returns: Minimum key length.
         */
        final @property inout(uint) minKeyLength() inout const pure nothrow @safe @nogc
        {
            return minKeyLength_;
        }

        /**
         * Returns: Maximum key length.
         */
        final @property inout(uint) maxKeyLength() inout const pure nothrow @safe @nogc
        {
            return maxKeyLength_;
        }
    }
    else
    {
        static assert(false, "Max should be larger or equal to Min");
    }
}
