
import matplotlib.pyplot as plt

x = []
y = []

with open('gnu_graph.dat', 'r') as file:
    for line in file:
        if not line.startswith('#'):
            parts = line.split()
            x.append(float(parts[1]))
            y.append(float(parts[2]))

plt.plot(x, y)
plt.xlabel('cycle label')
plt.ylabel('sum label')
plt.title('Plot title')
plt.grid(True)

plt.savefig('plot.png')

plt.show()