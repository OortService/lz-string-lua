dofile(ROOT_DIR..'/luabit/bit.lua')
utf8 = dofile(ROOT_DIR..'/lua_utf8/utf8.lua')

function charAt(str, index)
    return strsub(str, index, index)
end

function decompress(compressed)
    -- a string dada não contém dados
    if not compressed or compressed == '' then
        return ''
    end

    local dictionary = {}

    local enlargeIn = 4
    local dictSize = 4
    local numBits = 3

    local entry = ''
    local result = ''
    local w = ''
    local c = ''

    local nnext = 0
    local resb = 0

    local data_string = compressed
    local data_index, data_val = utf8.decode(compressed, 1)
    local data_position = 32768

    local index = 1
    while index < 10 do
        dictionary[index] = ''
        index = index + 1
    end

    local bits = 0
    local maxpower = 2 ^ 2
    local power = 1
    local resb_bor = 0

    while power ~= maxpower do
        -- resb = data_val & data_position
        resb = bit.band(data_val, data_position)

        -- data_position = >>= 1
        data_position = bit.blogic_rshift(data_position, 1)

        if data_position == 0 then
            data_position = 32768
            data_index, data_val = utf8.decode(data_string, data_index)
        end
        -- bits |= (1 if resb > 0 else 0) * power
        if resb > 0 then
            resb_bor = 1 * power
        else
            resb_bor = 0 * power
        end
        bits = bit.bor(bits, resb_bor)

        -- power <<= 1
        power = bit.blshift(power, 1)
    end

    nnext = bits

    if nnext == 0 then
        bits = 0
        maxpower = 2 ^ 8
        power = 1

        while power ~= maxpower do
            -- resb = data_val & data_position
            resb = bit.band(data_val, data_position)

            -- data_position >>= 1
            data_position = bit.blogic_rshift(data_position, 1)

            if data_position == 0 then
                data_position = 32768
                data_index, data_val = utf8.decode(data_string, data_index)
            end

            -- bits |= (1 if resb > 0 else 0) * power
            if resb > 0 then
                resb_bor = 1 * power
            else
                resb_bor = 0 * power
            end
            bits = bit.bor(bits, resb_bor)

            -- power <<= 1
            power = bit.blshift(power, 1)
        end

        --c = six.unichr(bits)
        c = utf8.encode_args(bits)

    elseif nnext == 1 then
        bits = 0
        maxpower = 2 ^ 16
        power = 1

        while power ~= maxpower do
            -- resb = data_val & data_position
            resb = bit.band(data_val, data_position)

            -- data_position >>= 1
            data_position = bit.blogic_rshift(data_position, 1)

            if data_position == 0 then
                data_position = 32768
                data_index, data_val = utf8.decode(data_string, data_index)
            end
            -- bits |= (1 if resb > 0 else 0) * power
            if resb > 0 then
                resb_bor = 1 * power
            else
                resb_bor = 0 * power
            end
            bits = bit.bor(bits, resb_bor)

            -- power <<= 1
            power = bit.blshift(power, 1)
        end

        -- c = six.unichr(bits)
        c = utf8.encode_args(bits)
    elseif nnext == 2 then
        return ''
    end

    dictionary[3] = c
    result = c
    w = result

    while 1 do
        if data_index > strlen(data_string) + 1 then
            return ''
        end

        bits = 0
        maxpower = 2 ^ numBits
        power = 1

        while power ~= maxpower do
            -- resb = data_val & data_position
            resb = bit.band(data_val, data_position)

            -- data_position >>= 1
            data_position = bit.blogic_rshift(data_position, 1)

            if data_position == 0 then
                data_position = 32768
                data_index, data_val = utf8.decode(data_string, data_index)
            end

            -- bits |= (1 if resb > 0 else 0) * power
            if resb > 0 then
                resb_bor = 1 * power
            else
                resb_bor = 0 * power
            end
            bits = bit.bor(bits, resb_bor)

            -- power <<= 1
            power = bit.blshift(power, 1)
        end

        c = bits

        if c == 0 then
            bits = 0
            maxpower = 2 ^ 8
            power = 1

            while power ~= maxpower do
                -- resb = data_val & data_position
                resb = bit.band(data_val, data_position)

                -- data_position >>= 1
                data_position = bit.blogic_rshift(data_position, 1)

                if data_position == 0 then
                    data_position = 32768
                    data_index, data_val = utf8.decode(data_string, data_index)
                end
                --bits |= (1 if resb > 0 else 0) * power
                if resb > 0 then
                    resb_bor = 1 * power
                else
                    resb_bor = 0 * power
                end
                bits = bit.bor(bits, resb_bor)

                -- power <<= 1
                power = bit.blshift(power, 1)
            end

            dictionary[dictSize] = utf8.encode_args(bits)
            dictSize = dictSize + 1
            c = dictSize - 1
            enlargeIn = enlargeIn - 1

        elseif c == 1 then
            bits = 0
            maxpower = 2 ^ 16
            power = 1

            while power ~= maxpower do
                -- resb = data_val & data_position
                resb = bit.band(data_val, data_position)

                -- data_position >>= 1
                data_position = bit.blogic_rshift(data_position, 1)

                if data_position == 0 then
                    data_position = 32768
                    data_index, data_val = utf8.decode(data_string, data_index)
                end
                -- bits |= (1 if resb > 0 else 0) * power
                if resb > 0 then
                    resb_bor = 1 * power
                else
                    resb_bor = 0 * power
                end
                bits = bit.bor(bits, resb_bor)

                -- power <<= 1
                power = bit.blshift(power, 1)
            end

            dictionary[dictSize] = utf8.encode_args(bits)
            dictSize = dictSize + 1

            c = dictSize - 1
            enlargeIn = enlargeIn - 1

        elseif c == 2 then
            return result
        end

        if enlargeIn == 0 then
            enlargeIn = 2 ^ numBits
            numBits = numBits + 1
        end

        if dictionary[c] then
            entry = dictionary[c]
        else
            if c == dictSize then
                entry = w .. charAt(w, 1)
            else
                return nil
            end
        end

        result = result .. entry

        dictionary[dictSize] = w .. charAt(entry, 1)

        dictSize = dictSize + 1
        enlargeIn = enlargeIn - 1
        w = entry

        if enlargeIn == 0 then
            enlargeIn = 2 ^ numBits
            numBits = numBits + 1
        end
    end
end


function decompresFromBase64(iinput)
    if not iinput or iinput == '' then
        return ''
    end
    local keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="

    local output = ''
    local output_ = ''
    local ol = 0
    local index = 1

    -- corrige eventuais carecteres inválidos
    iinput = gsub(iinput, '[^A-Za-z0-9\+\/\=]', '')

    local enc1 = ''
    local enc2 = ''
    local enc3 = ''
    local enc4 = ''

    local chr1 = 0
    local chr2 = 0
    local chr3 = 0

    while index < strlen(iinput) do
        enc1 = strfind(keyStr, charAt(iinput, index)) - 1
        index = index + 1

        enc2 = strfind(keyStr, charAt(iinput, index)) - 1
        index = index + 1

        enc3 = strfind(keyStr, charAt(iinput, index)) - 1
        index = index + 1

        enc4 = strfind(keyStr, charAt(iinput, index)) - 1
        index = index + 1

        -- chr1 = (enc1 << 2) | (enc2 >> 4)
        chr1 = bit.bor(
            bit.blshift(enc1, 2),
            bit.blogic_rshift(enc2, 4)
        )
        -- chr2 = ((enc2 & 15) << 4) | (enc3 >> 2)
        chr2 = bit.bor(
            bit.blshift(bit.band(enc2, 15), 4),
            bit.blogic_rshift(enc3, 2)
        )
        -- chr3 = ((enc3 & 3) << 6) | enc4
        chr3 = bit.bor(
            bit.blshift(bit.band(enc3, 3), 6),
            enc4)

        if mod(ol, 2) == 0 then
            -- output_ = chr1 << 8
            output_ = bit.blshift(chr1, 8)

            if enc3 ~= 64 then -- output += six.unichr(output_ | chr2)
                output = output .. utf8.encode_args(bit.bor(output_, chr2))
            end
            if enc4 ~= 64 then -- output_ = chr3 << 8
                output_ = bit.blshift(chr3, 8)
            end
        else
            -- output = output + six.unichr(output_ | chr1)
            output = output .. utf8.encode_args(bit.bor(output_, chr1))

            if enc3 ~= 64 then -- output_ = chr2 << 8
                output_ = bit.blshift(chr2, 8)
            end

            if enc4 ~= 64 then -- output += six.unichr(output_ | chr3)
                output = output .. utf8.encode_args(bit.bor(output_, chr3))
            end
        end
        ol = ol + 3
    end
    return decompress(output)
end