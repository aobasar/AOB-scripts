#!/bin/bash

# Stock Price Checker for macOS
# Usage: ./stock_price.sh AAPL

if [ -z "$1" ]; then
    echo "Usage: $0 <STOCK_SYMBOL>"
    echo "Example: $0 AAPL"
    exit 1
fi

SYMBOL=$(echo "$1" | tr '[:lower:]' '[:upper:]')

echo "Fetching price for $SYMBOL..."

# Try Yahoo Finance first
URL="https://query1.finance.yahoo.com/v8/finance/chart/$SYMBOL?range=1y&interval=1d"

RESPONSE=$(curl -s -A "Mozilla/5.0" "$URL")

# Check if we got valid data
if [ -z "$RESPONSE" ] || echo "$RESPONSE" | grep -q "Will be right back"; then
    echo "Error: Could not connect to Yahoo Finance"
    exit 1
fi

if echo "$RESPONSE" | grep -q '"code":"Not Found"'; then
    echo "Error: Symbol '$SYMBOL' not found"
    exit 1
fi

# Try to extract price using multiple methods
PRICE=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['chart']['result'][0]['meta']['regularMarketPrice'])" 2>/dev/null)

# If Python method failed, try sed
if [ -z "$PRICE" ]; then
    PRICE=$(echo "$RESPONSE" | sed -E 's/.*"regularMarketPrice":([0-9.]+).*/\1/' | grep -E '^[0-9.]+$' | head -1)
fi

# If still no price, try another pattern
if [ -z "$PRICE" ]; then
    PRICE=$(echo "$RESPONSE" | grep -o '"regularMarketPrice":[0-9.]*' | head -1 | cut -d':' -f2)
fi

if [ -z "$PRICE" ] || [ "$PRICE" = "null" ]; then
    echo "Error: Could not extract price from response"
    echo "Trying alternative API..."
    
    # Alternative: use finnhub (backup)
    ALT_URL="https://finnhub.io/api/v1/quote?symbol=$SYMBOL&token=demo"
    ALT_RESPONSE=$(curl -s "$ALT_URL")
    
    PRICE=$(echo "$ALT_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('c', ''))" 2>/dev/null)
    
    if [ -z "$PRICE" ] || [ "$PRICE" = "0" ]; then
        echo "Error: Could not fetch price for $SYMBOL"
        echo "Please check if the symbol is correct and try again"
        exit 1
    fi
    
    PREV_CLOSE=$(echo "$ALT_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('pc', ''))" 2>/dev/null)
    DAY_HIGH=$(echo "$ALT_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('h', ''))" 2>/dev/null)
    DAY_LOW=$(echo "$ALT_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('l', ''))" 2>/dev/null)
    
    CHANGE=$(echo "$PRICE - $PREV_CLOSE" | bc)
    CHANGE_PERCENT=$(echo "scale=2; ($CHANGE / $PREV_CLOSE) * 100" | bc)
    
    if [ "$(echo "$CHANGE >= 0" | bc)" -eq 1 ]; then
        SIGN="+"
    else
        SIGN=""
    fi
    
    echo "$SYMBOL: \$$PRICE ($SIGN$CHANGE, $CHANGE_PERCENT%) | Day Range: \$$DAY_LOW - \$$DAY_HIGH | (Historical data not available with backup API)"
    exit 0
fi

# Extract other current data
PREV_CLOSE=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['chart']['result'][0]['meta'].get('chartPreviousClose', data['chart']['result'][0]['meta'].get('previousClose', '')))" 2>/dev/null)
DAY_HIGH=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['chart']['result'][0]['meta']['regularMarketDayHigh'])" 2>/dev/null)
DAY_LOW=$(echo "$RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['chart']['result'][0]['meta']['regularMarketDayLow'])" 2>/dev/null)

# If Python failed, try sed
if [ -z "$PREV_CLOSE" ]; then
    PREV_CLOSE=$(echo "$RESPONSE" | sed -E 's/.*"chartPreviousClose":([0-9.]+).*/\1/' | grep -E '^[0-9.]+$' | head -1)
    [ -z "$PREV_CLOSE" ] && PREV_CLOSE=$(echo "$RESPONSE" | sed -E 's/.*"previousClose":([0-9.]+).*/\1/' | grep -E '^[0-9.]+$' | head -1)
fi

if [ -z "$DAY_HIGH" ]; then
    DAY_HIGH=$(echo "$RESPONSE" | sed -E 's/.*"regularMarketDayHigh":([0-9.]+).*/\1/' | grep -E '^[0-9.]+$' | head -1)
fi

if [ -z "$DAY_LOW" ]; then
    DAY_LOW=$(echo "$RESPONSE" | sed -E 's/.*"regularMarketDayLow":([0-9.]+).*/\1/' | grep -E '^[0-9.]+$' | head -1)
fi

# Calculate daily change
CHANGE=$(echo "$PRICE - $PREV_CLOSE" | bc)
CHANGE_PERCENT=$(echo "scale=2; ($CHANGE / $PREV_CLOSE) * 100" | bc | sed 's/\.00$//' | sed 's/0$//' | sed 's/\.$//')

# Extract historical prices using Python
HIST_DATA=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    closes = data['chart']['result'][0]['indicators']['quote'][0]['close']
    timestamps = data['chart']['result'][0]['timestamp']
    # Filter out None values
    prices = [(ts, price) for ts, price in zip(timestamps, closes) if price is not None]
    print(len(prices))
    if len(prices) > 0:
        print(prices[-1][1])  # current
        if len(prices) >= 7: print(prices[-7][1])
        else: print('NA')
        if len(prices) >= 30: print(prices[-30][1])
        else: print('NA')
        if len(prices) >= 90: print(prices[-90][1])
        else: print('NA')
        if len(prices) >= 180: print(prices[-180][1])
        else: print('NA')
        if len(prices) >= 252: print(prices[-252][1])
        else: print('NA')
        # YTD
        import time
        current_year = time.localtime().tm_year
        jan1_ts = int(time.mktime((current_year, 1, 1, 0, 0, 0, 0, 0, 0)))
        ytd_price = 'NA'
        for ts, price in prices:
            if ts >= jan1_ts:
                ytd_price = price
                break
        print(ytd_price)
except:
    print('0')
" 2>/dev/null)

if [ -n "$HIST_DATA" ]; then
    IFS=$'\n' read -d '' -ra HIST_ARRAY <<< "$HIST_DATA"
    
    if [ "${HIST_ARRAY[0]}" != "0" ] && [ ${#HIST_ARRAY[@]} -ge 7 ]; then
        CURRENT_HIST=${HIST_ARRAY[1]}
        
        # 7 days
        if [ "${HIST_ARRAY[2]}" != "NA" ]; then
            CHANGE_7D=$(echo "scale=2; (($CURRENT_HIST - ${HIST_ARRAY[2]}) / ${HIST_ARRAY[2]}) * 100" | bc | sed 's/\.00$//' | sed 's/0$//' | sed 's/\.$//')
        else
            CHANGE_7D="N/A"
        fi
        
        # 30 days
        if [ "${HIST_ARRAY[3]}" != "NA" ]; then
            CHANGE_30D=$(echo "scale=2; (($CURRENT_HIST - ${HIST_ARRAY[3]}) / ${HIST_ARRAY[3]}) * 100" | bc | sed 's/\.00$//' | sed 's/0$//' | sed 's/\.$//')
        else
            CHANGE_30D="N/A"
        fi
        
        # 90 days
        if [ "${HIST_ARRAY[4]}" != "NA" ]; then
            CHANGE_90D=$(echo "scale=2; (($CURRENT_HIST - ${HIST_ARRAY[4]}) / ${HIST_ARRAY[4]}) * 100" | bc | sed 's/\.00$//' | sed 's/0$//' | sed 's/\.$//')
        else
            CHANGE_90D="N/A"
        fi
        
        # 180 days
        if [ "${HIST_ARRAY[5]}" != "NA" ]; then
            CHANGE_180D=$(echo "scale=2; (($CURRENT_HIST - ${HIST_ARRAY[5]}) / ${HIST_ARRAY[5]}) * 100" | bc | sed 's/\.00$//' | sed 's/0$//' | sed 's/\.$//')
        else
            CHANGE_180D="N/A"
        fi
        
        # 1 year
        if [ "${HIST_ARRAY[6]}" != "NA" ]; then
            CHANGE_1Y=$(echo "scale=2; (($CURRENT_HIST - ${HIST_ARRAY[6]}) / ${HIST_ARRAY[6]}) * 100" | bc | sed 's/\.00$//' | sed 's/0$//' | sed 's/\.$//')
        else
            CHANGE_1Y="N/A"
        fi
        
        # YTD
        if [ "${HIST_ARRAY[7]}" != "NA" ]; then
            CHANGE_YTD=$(echo "scale=2; (($CURRENT_HIST - ${HIST_ARRAY[7]}) / ${HIST_ARRAY[7]}) * 100" | bc | sed 's/\.00$//' | sed 's/0$//' | sed 's/\.$//')
        else
            CHANGE_YTD="N/A"
        fi
    else
        CHANGE_7D="N/A"
        CHANGE_30D="N/A"
        CHANGE_90D="N/A"
        CHANGE_180D="N/A"
        CHANGE_1Y="N/A"
        CHANGE_YTD="N/A"
    fi
else
    CHANGE_7D="N/A"
    CHANGE_30D="N/A"
    CHANGE_90D="N/A"
    CHANGE_180D="N/A"
    CHANGE_1Y="N/A"
    CHANGE_YTD="N/A"
fi

# Format output
if [ "$(echo "$CHANGE >= 0" | bc)" -eq 1 ]; then
    SIGN="+"
else
    SIGN=""
fi

echo "$SYMBOL: \$$PRICE ($SIGN$CHANGE, $CHANGE_PERCENT%) | Day Range: \$$DAY_LOW - \$$DAY_HIGH | 7D: $CHANGE_7D% | 30D: $CHANGE_30D% | 90D: $CHANGE_90D% | 180D: $CHANGE_180D% | 1Y: $CHANGE_1Y% | YTD: $CHANGE_YTD%"