using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSServiceBus.Outputs
{
    public class SbQueue
    {
        public string Name { get; set; }
        public long ActiveMessages { get; set; }
        public long DeadLetteredMessages { get; set; }
    }
}
