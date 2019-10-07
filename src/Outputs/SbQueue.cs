namespace PSServiceBus.Outputs
{
    public class SbQueue
    {
        public string Name { get; set; }
        public long ActiveMessages { get; set; }
        public long DeadLetteredMessages { get; set; }
    }
}
