#!/bin/bash
# 請將此腳本放在 LAB1/ 目錄下，並在 LAB1/ 目錄下執行此腳本

set -e

# --- 0. 環境檢查 ---
echo "================================================="
echo
echo "--- 步驟 0: 檢查環境與工具版本 ---"

echo 
echo "[ 1. Ubuntu 版本 ]"
if [ -f /etc/os-release ]; then
    grep PRETTY_NAME /etc/os-release | cut -d'=' -f2 | tr -d '"'
else
    echo "無法讀取 /etc/os-release. 請手動確認 Ubuntu 版本。"
fi

echo
echo "[ 2. iverilog 版本 ] (應為 11.0-1.1)"
iverilog -V | head -n 1

echo
echo "[ 3. Yosys 版本 ]"
yosys -V

echo
echo "[ 4. Nangate 庫檢查 ]"
NANGATE_LIB_PATH="$HOME/nangate45/NanGate45/lib/NangateOpenCellLibrary_typical.lib"
if [ -f "$NANGATE_LIB_PATH" ]; then
    echo "Nangate 庫位置正確"
else
    echo "!! 警告 !!"
    echo "在 $NANGATE_LIB_PATH 未找到 Nangate 庫檔案。"
    echo "請確保 nangate45 庫位於 '~/nangate45/'"
    exit 1
fi
echo

# --- 1. 模擬 (Simulation) ---
echo "================================================="
echo
echo "--- 步驟 1: 開始測試 ---"

total=0

for i in 1 2 3 4
do
  iverilog -g2012 -o simv_I$i -DI$i -DLOCAL ./code/src/*.v ./code/supplied/*.v ./code/tb/*.v

  if [ $? -ne 0 ]; then
    echo "Compile failed for I$i"
    exit 1
  fi

  # 擷取 cycle（grep 找到那行，再用 awk 抓最後一個欄位）
  cycle=$(vvp simv_I$i | grep "Total execution cycle" | awk '{print $5}')
  
  echo "I$i execution cycle : $cycle"
  total=$((total + cycle))
done

echo "Total cycle: $total"

rm -rf simv* a.out

echo

# --- 2. 合成 (Synthesis) ---
echo "================================================="
echo
echo "--- 步驟 2: 開始 Yosys 合成 ---"

yosys -l ./log/cpu_syn.log -p "
 read_liberty -lib $NANGATE_LIB_PATH;
 read_verilog ./code/src/*.v;
 hierarchy -top CPU;
 proc; opt_clean;
 fsm; opt_clean;
 techmap; opt_clean;
 flatten CPU;
 dfflibmap -liberty $NANGATE_LIB_PATH;
 abc -liberty $NANGATE_LIB_PATH;
 stat -liberty $NANGATE_LIB_PATH;
" > /dev/null

yosys -l ./log/cache_syn.log -p "
 read_liberty -lib $NANGATE_LIB_PATH;
 read_verilog ./code/src/cache.v;
 hierarchy -top Cache;
 proc; opt_clean;
 fsm; opt_clean;
 techmap; opt_clean;
 flatten Cache;
 dfflibmap -liberty $NANGATE_LIB_PATH;
 abc -liberty $NANGATE_LIB_PATH;
 stat -liberty $NANGATE_LIB_PATH;
" > /dev/null

echo "合成完成！已生成 log/*_syn.log"
echo

# --- 3. 面積分析 (Area Results) ---
echo "================================================="
echo
echo "--- 步驟 3: 執行面積分析 ---"
python3 ./parse.py
echo

echo "================================================="
echo
echo "--- 批量測試腳本執行完畢 ---"
