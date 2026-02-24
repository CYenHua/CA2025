import matplotlib
# 在 import pyplot 之前加入這行，強制使用不需螢幕的後端模式
matplotlib.use('Agg') 

import matplotlib.pyplot as plt

# ==========================================
# 步驟 1: 填入數據
# ==========================================
cache_sizes = [4, 5, 7, 8, 9] 
latencies = [6000, 3000, 2980, 2750, 2700, 2700] 

# ==========================================
# 步驟 2: 設定圖表
# ==========================================
plt.figure(figsize=(8, 4.5)) 
plt.plot(cache_sizes, latencies, color='#5a85ce', linewidth=2)

# 標題與軸標籤
plt.title("Size vs Latency (Latency: 2000-7000)", fontsize=16, pad=15)
plt.xlabel("Size", fontsize=12)
plt.ylabel("Execution Cycles", fontsize=12) # 改成 Execution Cycles 更精確

# 設定範圍
plt.ylim(2000, 7000)
plt.xlim(0, max(cache_sizes) * 1.1) 

# 格線與背景
plt.grid(True, linestyle='-', alpha=0.6)

# ==========================================
# 步驟 3: 存檔 (取代 show)
# ==========================================
output_filename = 'latency_chart.png'
plt.savefig(output_filename, dpi=300, bbox_inches='tight')

print(f"圖表已儲存為: {output_filename}")