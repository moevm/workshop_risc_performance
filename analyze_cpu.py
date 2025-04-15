import sys
import matplotlib.pyplot as plt
from datetime import datetime

def parse_atop_log(logfile):
    cpu_data = []
    start_time = None
    skip_next_line = False

    with open(logfile, 'r') as f:
        for line in f:
            if skip_next_line:
                skip_next_line = False
                continue

            parts = line.strip().split()
            if not parts:
                continue

            if 'RESET' in parts:
                skip_next_line = True
                continue

            if parts[0] == 'CPU' and len(parts) > 3:
                timestamp = datetime.strptime(parts[3] + ' ' + parts[4], '%Y/%m/%d %H:%M:%S')
                if not start_time:
                    start_time = timestamp

                numcpu = int(parts[7])
                idle = float(parts[11])
                cpu_usage = (100 * numcpu - idle) / numcpu

                elapsed = (timestamp - start_time).total_seconds()

                cpu_data.append((elapsed, cpu_usage))

    return cpu_data

def plot_results(cpu_data):
    plt.figure(figsize=(12, 8))
    
    plt.subplot(2, 1, 1)
    times, usage = zip(*cpu_data)
    plt.plot(times, usage, 'r-', label='CPU Usage')
    plt.ylabel('CPU Usage (%)')
    plt.title('System Resource Usage')
    plt.grid(True)
    
    plt.tight_layout()
    plt.savefig('cpu_plot.png')
    # plt.show()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 analyze_stats.py <atop.log>")
        sys.exit(1)
        
    cpu = parse_atop_log(sys.argv[1])
    
    # print("\nСтатистика CPU:")
    # print(f"Максимальная нагрузка: {max(u for t,u in cpu):.2f}%")
    # print(f"Средняя нагрузка: {sum(u for t,u in cpu)/len(cpu):.2f}%")

    plot_results(cpu)