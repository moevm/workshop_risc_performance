import sys
import matplotlib.pyplot as plt

def parse_free_log(logfile):
    ram_data = []

    with open(logfile, 'r') as f:
        index = 0
        for _, line in enumerate(f):
            if line.startswith('Total:'):
                index += 1
                parts = line.split()
                total = float(parts[1])
                used = float(parts[2])

                ram_usage = (used / total) * 100
                ram_data.append((index, ram_usage))

    return ram_data

def plot_results(ram_data):
    plt.figure(figsize=(12, 8))

    plt.subplot(2, 1, 1)
    times, usage = zip(*ram_data)
    plt.plot(times, usage, 'b-', label='RAM Usage')
    plt.ylabel('RAM Usage (%)')
    plt.title('RAM Usage Over Time')
    plt.xlabel('Sample Index')
    plt.grid(True)

    plt.tight_layout()
    plt.savefig('ram_plot.png')
    # plt.show()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 analyze_ram.py <free.log>")
        sys.exit(1)

    ram = parse_free_log(sys.argv[1])

    # print("\nСтатистика RAM:")
    # print(f"Максимальная нагрузка: {max(u for t,u in ram):.2f}%")
    # print(f"Средняя нагрузка: {sum(u for t,u in ram)/len(ram):.2f}%")

    plot_results(ram)