instrument { name = "script astrahvh", overlay = true, icon = "indicators:BB" }

period = input (20, "Perodo", input.integer, 1)
devs   = input (1, "Desvio Padro", input.integer, 1)

overbought = input (1, "Sobrecompra", input.double, -2, 2, 0.1, false)
oversold = input (0, "Sobrevenda", input.double, -2, 2, 0.1, false)

source = input (1, "Fonte do Indicador", input.string_selection, inputs.titles)
    fn     = input (1, "Mdia Mvel", input.string_selection, averages.titles)
    
    input_group {
        "RSI",
        period1 = input (7, "Perodo", input.integer, 1),
        source1 = input (1, "Fonte do Indicador", input.string_selection, inputs.titles),
            fn1     = input (averages.ssma, "Mdia Mvel", input.string_selection, averages.titles),
            
            color  = input { default = "#B42EFF", type = input.color },
            width  = input { default = 1, type = input.line_width}
        }
        
        local sourceSeries = inputs[source]
        local averageFunction = averages[fn]
        local sourceSeries1 = inputs[source1]
        local averageFunction1 = averages[fn1]
        
        CCIupLevel = 100
        CCIdnLevel = -100
        
        BBupLevel = 1
        BBdnLevel = 0
        
        RSIupLevel = 70
        RSIdnLevel = 30
        
        -- Bandas de Bollinger
        middle = averageFunction(sourceSeries, period)
        scaled_dev = devs * stdev(sourceSeries, period)
        
        top = middle + scaled_dev
        bottom = middle - scaled_dev
        
        bbr = (sourceSeries - bottom) / (top - bottom)
        
        -- RSI
        delta = sourceSeries1 - sourceSeries1[1]
        
        up1 = averageFunction(max(delta, 0), period)
        down1 = averageFunction(max(-delta, 0), period)
        
        rs = up1 / down1
        rsi = 100 - 100 / (1 + rs)
        
        src = close
        len = 7
        up = rma(max(change(src), 0), len)
        down = rma(-min(change(src), 0), len)
        
        rsi1 = iff(down == 0, 100, iff(up == 0, 0, 100 - (100 / (1 + up / down))))
        
        -- Mdias Mveis
        MAfast = 9
        MAslow = 21
        short = ema(close, MAfast)
        long = ema(close, MAslow)
        
        -- CCI
        period_cci = 20
        nom = hlc3 - sma(hlc3, period_cci)
        denom = mad(hlc3, period_cci) * 0.015
        
        cci = nom / denom
        
        -- **MACD**
        MACDfast = 12
        MACDslow = 26
        MACDsignal = 9
        
        macd_line = ema(close, MACDfast) - ema(close, MACDslow)
        signal_line = ema(macd_line, MACDsignal)
        
        -- **ADX**
        ADXperiod = 14
        dmi_plus = rma(max(high - high[1], 0), ADXperiod)
        dmi_minus = rma(max(low[1] - low, 0), ADXperiod)
        dx = abs(dmi_plus - dmi_minus) / (dmi_plus + dmi_minus) * 100
        adx = rma(dx, ADXperiod)
        
        -- **Condies para COMPRA**
        pu = (cci > CCIupLevel) and 
        (rsi > RSIupLevel) and 
        (bbr > BBupLevel) and 
        (open[1] > short[1] and close[1] > short[1]) and 
        (macd_line > signal_line) and  
        (adx > 25 and dmi_plus > dmi_minus)
        
        -- **Condies para VENDA**
        pd = (cci < CCIdnLevel) and 
        (rsi < RSIdnLevel) and 
        (bbr < BBdnLevel) and 
        (open[1] < short[1] and close[1] < short[1]) and 
        (macd_line < signal_line) and  
        (adx > 25 and dmi_minus > dmi_plus)
        
        -- Exibir sinais no grfico
        plot_shape(pd, "Venda", shape_style.triangledown, shape_size.large, 'red', shape_location.abovebar, 0, 'VENDER', 'red')
        plot_shape(pu, "Compra", shape_style.triangleup, shape_size.large, 'green', shape_location.belowbar, 0, 'COMPRAR', 'green')
        
        print(pu)
        