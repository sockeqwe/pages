fun secondsRemaining(now : Date, endDate : Date){
  val nowMilliseconds = now.getTime()
  val endMilliseconds = end.getTime()

  val nowSeconds = nowMilliseconds / 1000
  val endSeconds = endSeconds / 1000

  return endSeconds - nowSeconds
}


@Test
fun remaining_time_between_two_consecutive_days_is_86400_seconds(){
  val oneDayInSeconds = 1*24*60*60
  val format = SimpleDateFormat("yyyy-MM-dd")
  val d1 = format.parse("2012-01-15")
  val d2 = format.parse("2012-01-16")
    
  val remainingSeconds = secondsRemaining(d1, d2)

  Assert.assertEquals(oneDayInSeconds, remainingSeconds)
}