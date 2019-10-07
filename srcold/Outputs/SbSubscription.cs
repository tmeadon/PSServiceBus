namespace PSServiceBus.Outputs
{
    public class SbSubscription
    {
        public string Name { get; set; }
        public string Topic { get; set; }
        public long ActiveMessages { get; set; }
        public long DeadLetteredMessages { get; set; }
    }
}
